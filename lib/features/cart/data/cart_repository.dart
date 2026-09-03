import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_result.dart';
import 'cart_models.dart';

/// M27-M36 from the guide. Every mutation (add/update/remove/coupon/
/// gift-wrap/redeem) hands back the refreshed [CartData] so the notifier
/// never has to guess the new state locally.
class CartRepository {
  CartRepository(this._client);

  final ApiClient _client;

  /// M27: Current user shopping cart
  Future<ApiResult<CartData>> getCart() {
    return _client.get<CartData>(
      ApiEndpoints.cart,
      fromJson: (data) => CartData.fromJson(data as Map<String, dynamic>),
    );
  }

  /// M28: Add product variant to cart
  Future<ApiResult<CartData>> addItem({
    required String productId,
    int quantity = 1,
    String? selectedSize,
    String? selectedColor,
    List<Map<String, dynamic>>? selectedAddons,
  }) {
    return _client.post<CartData>(
      ApiEndpoints.cartItems,
      data: {
        'itemId': productId,
        'quantity': quantity,
        if (selectedSize != null) 'selectedSize': selectedSize,
        if (selectedColor != null) 'selectedColor': selectedColor,
        if (selectedAddons != null) 'selectedAddons': selectedAddons,
      },
      fromJson: (data) => CartData.fromJson(data as Map<String, dynamic>),
    );
  }

  /// M29: Update quantity or variant. The guide accepts either `PUT` or
  /// `PATCH`; using `PUT` since it's listed as canonical.
  Future<ApiResult<CartData>> updateItem(
    String cartItemId, {
    int? quantity,
    String? selectedSize,
    String? selectedColor,
  }) {
    return _mutateAndParse(() => _client.put<Map<String, dynamic>?>(
          ApiEndpoints.cartItem(cartItemId),
          data: {
            if (quantity != null) 'quantity': quantity,
            if (selectedSize != null) 'selectedSize': selectedSize,
            if (selectedColor != null) 'selectedColor': selectedColor,
          },
          fromJson: (data) => data is Map<String, dynamic> ? data : null,
        ));
  }

  /// M30: Remove single item from cart
  Future<ApiResult<CartData>> removeItem(String cartItemId) {
    return _mutateAndParse(() => _client.delete<Map<String, dynamic>?>(
          ApiEndpoints.cartItem(cartItemId),
          fromJson: (data) => data is Map<String, dynamic> ? data : null,
        ));
  }

  /// M31: Move cart item to favorites
  Future<ApiResult<CartData>> moveToFavorite(String cartItemId) {
    return _mutateAndParse(() => _client.post<Map<String, dynamic>?>(
          ApiEndpoints.cartItemFavorite(cartItemId),
          fromJson: (data) => data is Map<String, dynamic> ? data : null,
        ));
  }

  /// Some mutation endpoints hand back the full updated cart (matching
  /// `getCart()`'s `{vendors:[...]}` shape) and some don't (a bare ack, or
  /// no body at all e.g. `204 No Content`). Rather than assume one or the
  /// other and risk crashing on a cast, use the body when it actually looks
  /// like a cart and fall back to a fresh `GET /cart` otherwise — either
  /// way the caller gets authoritative post-mutation state.
  Future<ApiResult<CartData>> _mutateAndParse(
    Future<ApiResult<Map<String, dynamic>?>> Function() call,
  ) async {
    final result = await call();
    final error = result.errorOrNull;
    if (error != null) return ApiFailure<CartData>(error);
    final data = result.dataOrNull;
    if (data != null && (data.containsKey('vendors') || data.containsKey('items'))) {
      return ApiSuccess<CartData>(CartData.fromJson(data));
    }
    return getCart();
  }

  /// M32: Apply promo coupon code
  Future<ApiResult<CartData>> applyCoupon(String code) {
    return _mutateAndParse(() => _client.post<Map<String, dynamic>?>(
          ApiEndpoints.cartCoupon,
          data: {'code': code},
          fromJson: (data) => data is Map<String, dynamic> ? data : null,
        ));
  }

  /// M33: Remove applied promo coupon
  Future<ApiResult<CartData>> removeCoupon() {
    return _mutateAndParse(() => _client.delete<Map<String, dynamic>?>(
          ApiEndpoints.cartCoupon,
          fromJson: (data) => data is Map<String, dynamic> ? data : null,
        ));
  }

  /// M34: Add luxury gift wrapping & card note. The guide's body is just
  /// `{giftWrap, giftMessage}` — no recipient name or wrap-type fields.
  Future<ApiResult<CartData>> setGiftWrap({
    required bool giftWrap,
    String? giftMessage,
  }) {
    return _mutateAndParse(() => _client.patch<Map<String, dynamic>?>(
          ApiEndpoints.cartGiftWrap,
          data: {
            'giftWrap': giftWrap,
            if (giftMessage != null) 'giftMessage': giftMessage,
          },
          fromJson: (data) => data is Map<String, dynamic> ? data : null,
        ));
  }

  /// M35: Redeem loyalty points for discount
  Future<ApiResult<CartData>> redeemPoints(int points) {
    return _mutateAndParse(() => _client.post<Map<String, dynamic>?>(
          ApiEndpoints.cartRedeemPoints,
          data: {'points': points},
          fromJson: (data) => data is Map<String, dynamic> ? data : null,
        ));
  }

  /// M36: Recalculate summary breakdown
  Future<ApiResult<CartTotals>> getTotals() {
    return _client.get<CartTotals>(
      ApiEndpoints.cartTotals,
      fromJson: (data) => CartTotals.fromJson(data as Map<String, dynamic>),
    );
  }
}
