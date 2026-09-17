import 'dart:async';
import 'package:app_links/app_links.dart';

/// Google Pay and Apple Pay can't run inside the app's embedded WebView —
/// Chrome disables the PaymentRequest API inside Android WebView, and Apple
/// restricts ApplePaySession to Safari/system-browser contexts. Those two
/// methods are opened in the system browser instead (see
/// `PaymentWebviewScreen`'s `openExternally` mode), so MyFatoorah's redirect
/// to `safa://payment/...` no longer lands inside our own WebView where
/// `onNavigationRequest` could catch it — it comes back through the OS as a
/// real deep link (registered in AndroidManifest.xml / Info.plist), which is
/// what this service listens for.
class PaymentDeepLinkService {
  PaymentDeepLinkService._();

  static final PaymentDeepLinkService instance = PaymentDeepLinkService._();

  final AppLinks _appLinks = AppLinks();
  final StreamController<Uri> _controller = StreamController<Uri>.broadcast();
  StreamSubscription<Uri>? _sub;

  Stream<Uri> get onPaymentCallback => _controller.stream;

  Future<void> init() async {
    if (_sub != null) return;
    _sub = _appLinks.uriLinkStream.listen((uri) {
      if (uri.scheme == 'safa') _controller.add(uri);
    });

    // Covers the case where the app was killed while the customer was
    // paying in the browser and the redirect relaunched it cold.
    final initial = await _appLinks.getInitialLink();
    if (initial != null && initial.scheme == 'safa') {
      _controller.add(initial);
    }
  }
}
