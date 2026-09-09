import 'package:flutter_test/flutter_test.dart';
import 'package:sfa/features/checkout/presentation/screens/payment_webview_screen.dart';

/// The webview used to treat *any* callback redirect as a completed
/// payment, so a declined card landed the customer on the green success
/// screen. These pin down the rule that only an explicit "paid" signal
/// counts as success.
void main() {
  group('paymentOutcomeOf', () {
    test('returns null while still inside the gateway flow', () {
      expect(paymentOutcomeOf('https://demo.myfatoorah.com/pay/12345'), isNull);
      expect(paymentOutcomeOf('https://bank.example.com/3ds/challenge'), isNull);
    });

    test('recognises success by path and by status parameter', () {
      expect(
        paymentOutcomeOf('safa://payment/success'),
        PaymentOutcome.paid,
      );
      expect(
        paymentOutcomeOf('https://api.example.com/payment/callback?status=PAID'),
        PaymentOutcome.paid,
      );
    });

    test('recognises failure by path and by status parameter', () {
      expect(
        paymentOutcomeOf('safa://payment/failure'),
        PaymentOutcome.failed,
      );
      expect(
        paymentOutcomeOf('https://api.example.com/payment/callback?status=FAILED'),
        PaymentOutcome.failed,
      );
    });

    test('recognises cancellation', () {
      expect(paymentOutcomeOf('safa://payment/cancel'), PaymentOutcome.cancelled);
      expect(
        paymentOutcomeOf('https://api.example.com/payment/cb?status=CANCELLED'),
        PaymentOutcome.cancelled,
      );
    });

    test('an unrecognised callback is never reported as paid', () {
      expect(paymentOutcomeOf('safa://payment'), PaymentOutcome.failed);
      expect(paymentOutcomeOf('safa://payment/whatever'), PaymentOutcome.failed);
    });
  });
}
