import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_result.dart';
import 'payment_models.dart';

/// M44-M48 from the guide.
class PaymentsRepository {
  PaymentsRepository(this._client);

  final ApiClient _client;

  /// M44: List customer saved payment methods
  Future<ApiResult<List<SavedPaymentMethod>>> getPaymentMethods() {
    return _client.get<List<SavedPaymentMethod>>(
      ApiEndpoints.paymentMethods,
      fromJson: (data) {
        final raw = data is Map<String, dynamic> && data['items'] is List
            ? data['items'] as List
            : (data is List ? data : const []);
        return raw
            .map((v) => SavedPaymentMethod.fromJson(v as Map<String, dynamic>))
            .toList();
      },
    );
  }

  /// M45: Initiate payment session (Mada/ApplePay via MyFatoorah)
  Future<ApiResult<PaymentInitiateResult>> initiatePayment({
    required String orderId,
    required String methodKey,
    int? methodMyfatoorahId,
  }) {
    return _client.post<PaymentInitiateResult>(
      ApiEndpoints.paymentInitiate,
      data: {
        'orderId': orderId,
        'methodKey': methodKey,
        if (methodMyfatoorahId != null) 'methodMyfatoorahId': methodMyfatoorahId,
      },
      fromJson: (data) => PaymentInitiateResult.fromJson(data as Map<String, dynamic>),
    );
  }

  /// M46: Get live, priced payment methods directly from MyFatoorah for a
  /// given amount — this is now the source of truth for what checkout
  /// offers, since it returns exactly the method codes and MyFatoorah ids
  /// `/payments/methods/initiate` expects back.
  Future<ApiResult<List<MyFatoorahPaymentMethod>>> getLiveMyFatoorahMethods({
    required double amount,
    String currency = 'SAR',
  }) {
    return _client.post<List<MyFatoorahPaymentMethod>>(
      ApiEndpoints.paymentMyFatoorah,
      data: {'amount': amount, 'currency': currency},
      fromJson: (data) {
        final raw = data is List ? data : const [];
        return raw
            .map((v) => MyFatoorahPaymentMethod.fromJson(v as Map<String, dynamic>))
            .toList();
      },
    );
  }

  /// M47: Save payment method (Mada/Apple Pay/Visa)
  Future<ApiResult<SavedPaymentMethod>> savePaymentMethod({
    required String type,
    required String cardToken,
    String? last4,
    String? brand,
    bool isDefault = false,
  }) {
    return _client.post<SavedPaymentMethod>(
      ApiEndpoints.paymentMethods,
      data: {
        'type': type,
        'cardToken': cardToken,
        if (last4 != null) 'last4': last4,
        if (brand != null) 'brand': brand,
        'isDefault': isDefault,
      },
      fromJson: (data) => SavedPaymentMethod.fromJson(data as Map<String, dynamic>),
    );
  }

  /// M48: Delete saved payment method
  Future<ApiResult<void>> deletePaymentMethod(String id) {
    return _client.delete<void>(ApiEndpoints.paymentDelete(id), fromJson: (_) {});
  }

  /// Set default payment method — noted alongside M48 in the guide.
  Future<ApiResult<void>> setDefaultPaymentMethod(String id) {
    return _client.patch<void>(ApiEndpoints.paymentSetDefault(id), fromJson: (_) {});
  }
}
