import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:sfa/core/localization/app_localizations.dart';
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

  const PaymentWebviewArgs({required this.paymentUrl, required this.order});
}

class PaymentWebviewScreen extends StatefulWidget {
  final String paymentUrl;
  final CheckoutConfirmResult order;

  const PaymentWebviewScreen({
    super.key,
    required this.paymentUrl,
    required this.order,
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
  late final WebViewController _controller;
  bool _loading = true;
  bool _handledCallback = false;

  @override
  void initState() {
    super.initState();
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

  void _onPaymentCallback(PaymentOutcome outcome) {
    if (_handledCallback || !mounted) return;
    _handledCallback = true;

    if (outcome == PaymentOutcome.paid) {
      context.pushReplacement('/payment-success', extra: widget.order);
      return;
    }

    // Unpaid: the order was still created, so tracking is where the
    // customer can see it and retry payment.
    final loc = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          loc.translate(
            outcome == PaymentOutcome.cancelled
                ? 'paymentCancelled'
                : 'paymentFailed',
          ),
        ),
      ),
    );
    context.pushReplacement('/order-tracking/${widget.order.orderId}');
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isAr = loc.isArabic;

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: context.palette.background,
        appBar: PrimaryAppBar(
          title: isAr ? 'إتمام الدفع' : 'Complete Payment',
          fontSize: 18,
          letterSpacing: 0,
          showBackButton: true,
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_loading) const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}
