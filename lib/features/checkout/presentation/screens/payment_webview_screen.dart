import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:sfa/core/localization/app_localizations.dart';
import 'package:sfa/core/navigation/payment_deep_link_service.dart';
import 'package:sfa/core/theme/app_palette.dart';
import 'package:sfa/core/widgets/primary_app_bar.dart';
import '../../data/checkout_models.dart';

/// Hosts the MyFatoorah/KNET hosted payment page returned by
/// `/payments/methods/initiate`. The gateway is configured to redirect to
/// this placeholder scheme once the user finishes paying — swap it for the
/// real success/failure callback URL(s) once the backend documents them.
const String paymentCallbackUrlPrefix = 'safa://payment';

/// How a redirect off the hosted page ended. Anything that isn't a
/// confirmed payment is *not* a success: the customer must never be shown
/// the green screen for a declined card or an abandoned session.
enum PaymentOutcome { paid, failed, cancelled }

class PaymentWebviewArgs {
  final String paymentUrl;
  final CheckoutConfirmResult order;

  /// True when this order already existed before the payment attempt (the
  /// "pay now" retry from the orders list, via `startOrderPayment`) rather
  /// than being freshly created by checkout. Checkout clears the cart the
  /// moment the order is created, so leaving without paying there needs to
  /// land somewhere else (the cart screen); a retry from the orders list
  /// touches nothing, so it should just return to that order page.
  final bool isOrderRetry;

  /// True for Apple Pay / Google Pay (see
  /// `MyFatoorahPaymentMethod.requiresExternalBrowser`): those wallets'
  /// web buttons don't function inside an embedded WebView, so the
  /// gateway page is opened in the system browser instead and this screen
  /// just waits for the `safa://payment/...` redirect to come back as an
  /// OS-level deep link.
  final bool openExternally;

  const PaymentWebviewArgs({
    required this.paymentUrl,
    required this.order,
    this.isOrderRetry = false,
    this.openExternally = false,
  });
}

class PaymentWebviewScreen extends StatefulWidget {
  final String paymentUrl;
  final CheckoutConfirmResult order;
  final bool isOrderRetry;
  final bool openExternally;

  const PaymentWebviewScreen({
    super.key,
    required this.paymentUrl,
    required this.order,
    this.isOrderRetry = false,
    this.openExternally = false,
  });

  @override
  State<PaymentWebviewScreen> createState() => _PaymentWebviewScreenState();
}

/// Classifies a redirect URL. Returns `null` while the customer is still
/// somewhere inside the gateway's own flow.
///
/// Both shapes the gateway can use are handled: a path segment
/// (`.../payment/success`) and a status query parameter
/// (`?status=PAID`). A callback on the app's own scheme that matches
/// neither is reported as [PaymentOutcome.failed] rather than guessed at —
/// the order stays unpaid and retryable, which is recoverable, whereas a
/// false "paid" is not.
@visibleForTesting
PaymentOutcome? paymentOutcomeOf(String url) {
  final lower = url.toLowerCase();
  final status = Uri.tryParse(url)?.queryParameters['status']?.toUpperCase();

  if (status == 'PAID' || status == 'SUCCESS' || status == 'SUCCESSFUL') {
    return PaymentOutcome.paid;
  }
  if (status == 'CANCELLED' || status == 'CANCELED') {
    return PaymentOutcome.cancelled;
  }
  if (status == 'FAILED' || status == 'FAILURE' || status == 'ERROR') {
    return PaymentOutcome.failed;
  }

  if (lower.contains('/payment/success')) return PaymentOutcome.paid;
  if (lower.contains('/payment/cancel')) return PaymentOutcome.cancelled;
  if (lower.contains('/payment/failure') || lower.contains('/payment/failed')) {
    return PaymentOutcome.failed;
  }

  if (lower.startsWith(paymentCallbackUrlPrefix)) return PaymentOutcome.failed;
  return null;
}

class _PaymentWebviewScreenState extends State<PaymentWebviewScreen> {
  WebViewController? _controller;
  bool _loading = true;
  bool _handledCallback = false;
  bool _launchFailed = false;
  StreamSubscription<Uri>? _deepLinkSub;

  @override
  void initState() {
    super.initState();
    if (widget.openExternally) {
      _launchExternally();
      _deepLinkSub = PaymentDeepLinkService.instance.onPaymentCallback.listen((
        uri,
      ) {
        final outcome = paymentOutcomeOf(uri.toString());
        if (outcome != null) _onPaymentCallback(outcome);
      });
      return;
    }
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _loading = true);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _loading = false);
          },
          onNavigationRequest: (request) {
            final outcome = paymentOutcomeOf(request.url);
            if (outcome == null) return NavigationDecision.navigate;
            _onPaymentCallback(outcome);
            return NavigationDecision.prevent;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  @override
  void dispose() {
    _deepLinkSub?.cancel();
    super.dispose();
  }

  Future<void> _launchExternally() async {
    final launched = await launchUrl(
      Uri.parse(widget.paymentUrl),
      mode: LaunchMode.externalApplication,
    );
    if (mounted) setState(() => _launchFailed = !launched);
  }

  void _onPaymentCallback(PaymentOutcome outcome) {
    if (_handledCallback || !mounted) return;

    if (outcome == PaymentOutcome.paid) {
      _handledCallback = true;
      context.pushReplacement('/payment-success', extra: widget.order);
      return;
    }

    _exitWithoutPayment(
      outcome == PaymentOutcome.cancelled ? 'paymentCancelled' : 'paymentFailed',
    );
  }

  /// Leaves the payment flow without a confirmed payment — via the back
  /// button, the system back gesture, or a cancelled/failed callback.
  ///
  /// [isOrderRetry] orders were already sitting unpaid before this attempt
  /// (the "pay now" retry from the orders list) and nothing about them
  /// changed by opening the gateway, so this just pops back to that order
  /// page. Checkout orders cleared the cart the moment they were created,
  /// so there's nothing for the checkout screen underneath to show — this
  /// uses `go` (not `pop`) to drop checkout and this webview from the stack
  /// and land on the cart screen instead of a stale checkout page.
  void _exitWithoutPayment([String? messageKey]) {
    if (_handledCallback || !mounted) return;
    _handledCallback = true;

    if (messageKey != null) {
      final loc = AppLocalizations.of(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(loc.translate(messageKey))));
    }
    if (widget.isOrderRetry) {
      context.pop();
    } else {
      context.go('/cart');
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isAr = loc.isArabic;

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (didPop) return;
          _exitWithoutPayment('paymentCancelled');
        },
        child: Scaffold(
          backgroundColor: context.palette.background,
          appBar: PrimaryAppBar(
            title: isAr ? 'إتمام الدفع' : 'Complete Payment',
            fontSize: 18,
            letterSpacing: 0,
            showBackButton: true,
            onBackTap: () => _exitWithoutPayment('paymentCancelled'),
          ),
          body: widget.openExternally
              ? _buildExternalWaitingBody(loc)
              : Stack(
                  children: [
                    WebViewWidget(controller: _controller!),
                    if (_loading)
                      const Center(child: CircularProgressIndicator()),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildExternalWaitingBody(AppLocalizations loc) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!_launchFailed) const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(
              loc.translate('waitingForExternalPayment'),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: context.palette.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: _launchExternally,
              child: Text(loc.translate('reopenPaymentPage')),
            ),
          ],
        ),
      ),
    );
  }
}
