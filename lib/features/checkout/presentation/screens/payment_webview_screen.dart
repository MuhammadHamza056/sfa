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
const String paymentCallbackUrlPrefix = 'sfa://payment-callback';

class PaymentWebviewArgs {
  final String paymentUrl;
  final CheckoutConfirmResult order;

  const PaymentWebviewArgs({required this.paymentUrl, required this.order});
}

class PaymentWebviewScreen extends StatefulWidget {
  final String paymentUrl;
  final CheckoutConfirmResult order;

  const PaymentWebviewScreen({super.key, required this.paymentUrl, required this.order});

  @override
  State<PaymentWebviewScreen> createState() => _PaymentWebviewScreenState();
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
            if (request.url.startsWith(paymentCallbackUrlPrefix)) {
              _onPaymentCallback();
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  void _onPaymentCallback() {
    if (_handledCallback) return;
    _handledCallback = true;
    context.pushReplacement('/payment-success', extra: widget.order);
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
