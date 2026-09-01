import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_result.dart';
import 'checkout_models.dart';

/// M37-M39 from the guide: delivery regions and the two-step checkout
/// (summary then create-order).
class CheckoutRepository {
  CheckoutRepository(this._client);

  final ApiClient _client;

  /// M37: Saudi 13 regions and cities
  Future<ApiResult<List<Region>>> getRegions() {
    return _client.get<List<Region>>(
      ApiEndpoints.regions,
      fromJson: (data) {
        final raw = data is Map<String, dynamic> && data['items'] is List
            ? data['items'] as List
            : (data is List ? data : const []);
        return raw.map((v) => Region.fromJson(v as Map<String, dynamic>)).toList();
      },
    );
  }

  /// M38: Final checkout summary with tax, delivery & totals
  Future<ApiResult<CheckoutPreview>> getCheckoutSummary({
    required String addressId,
    String? couponCode,
    bool? giftWrap,
  }) {
    return _client.get<CheckoutPreview>(
      ApiEndpoints.checkoutSummary,
      queryParameters: {
        'addressId': addressId,
        if (couponCode != null) 'couponCode': couponCode,
        if (giftWrap != null) 'giftWrap': giftWrap,
      },
      fromJson: (data) => CheckoutPreview.fromJson(data as Map<String, dynamic>),
    );
  }

  /// M39: Confirm checkout and place order
  Future<ApiResult<CheckoutConfirmResult>> confirmCheckout({
    required String addressId,
    required String paymentMethod,
    String deliveryMethod = 'DELIVERY',
    String? deliverySlot,
    String? promoCode,
  }) {
    return _client.post<CheckoutConfirmResult>(
      ApiEndpoints.checkoutCreateOrder,
      data: {
        'deliveryMethod': deliveryMethod,
        'addressId': addressId,
        'paymentMethod': paymentMethod,
        if (deliverySlot != null) 'deliverySlot': deliverySlot,
        if (promoCode != null) 'promoCode': promoCode,
      },
      fromJson: (data) => CheckoutConfirmResult.fromJson(data as Map<String, dynamic>),
    );
  }
}
