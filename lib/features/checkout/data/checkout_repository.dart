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

  /// M39: Confirm checkout and place order. `deliveryMethod` is lowercase
  /// (`'delivery'`) per the real confirm-order body — unlike
  /// `deliverySlot`/`paymentMethod`, which are uppercase enums.
  /// `giftWrap`/`giftMessage` carry the cart's gift-wrap choice onto the
  /// order, which then reports it back on `GET /orders`.
  Future<ApiResult<CheckoutConfirmResult>> confirmCheckout({
    required String addressId,
    required String paymentMethod,
    required Map<String, dynamic> shippingAddress,
    String deliveryMethod = 'delivery',
    String? deliverySlot,
    String? promoCode,
    String? paymentMethodId,
    bool? giftWrap,
    String? giftMessage,
  }) {
    return _client.post<CheckoutConfirmResult>(
      ApiEndpoints.checkoutCreateOrder,
      data: {
        'deliveryMethod': deliveryMethod,
        'addressId': addressId,
        'shippingAddress': shippingAddress,
        'paymentMethod': paymentMethod,
        if (paymentMethodId != null) 'paymentMethodId': paymentMethodId,
        if (deliverySlot != null) 'deliverySlot': deliverySlot,
        if (promoCode != null) 'promoCode': promoCode,
        // The backend falls back to the gift wrap stored on the cart when
        // these are omitted, but sending them keeps the order matching what
        // the cart screen showed even if the two ever drift.
        if (giftWrap != null) 'giftWrap': giftWrap,
        if (giftMessage != null && giftMessage.isNotEmpty) 'giftMessage': giftMessage,
      },
      fromJson: (data) => CheckoutConfirmResult.fromJson(data as Map<String, dynamic>),
    );
  }
}
