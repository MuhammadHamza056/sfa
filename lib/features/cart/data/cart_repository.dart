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
    return _client.put<CartData>(
      ApiEndpoints.cartItem(cartItemId),
      data: {
        if (quantity != null) 'quantity': quantity,
        if (selectedSize != null) 'selectedSize': selectedSize,
        if (selectedColor != null) 'selectedColor': selectedColor,
      },
      fromJson: (data) => CartData.fromJson(data as Map<String, dynamic>),
    );
  }

  /// M30: Remove single item from cart
  Future<ApiResult<CartData>> removeItem(String cartItemId) {
    return _client.delete<CartData>(
      ApiEndpoints.cartItem(cartItemId),
      fromJson: (data) => CartData.fromJson(data as Map<String, dynamic>),
    );
  }

  /// M31: Move cart item to favorites
  Future<ApiResult<CartData>> moveToFavorite(String cartItemId) {
    return _client.post<CartData>(
      ApiEndpoints.cartItemFavorite(cartItemId),
      fromJson: (data) => CartData.fromJson(data as Map<String, dynamic>),
    );
  }

  /// M32: Apply promo coupon code
  Future<ApiResult<CartData>> applyCoupon(String code) {
    return _client.post<CartData>(
      ApiEndpoints.cartCoupon,
      data: {'code': code},
      fromJson: (data) => CartData.fromJson(data as Map<String, dynamic>),
    );
  }

  /// M33: Remove applied promo coupon
  Future<ApiResult<CartData>> removeCoupon() {
    return _client.delete<CartData>(
      ApiEndpoints.cartCoupon,
      fromJson: (data) => CartData.fromJson(data as Map<String, dynamic>),
    );
  }

  /// M34: Add luxury gift wrapping & card note. The guide's body is just
  /// `{giftWrap, giftMessage}` — no recipient name or wrap-type fields.
  Future<ApiResult<CartData>> setGiftWrap({
    required bool giftWrap,
    String? giftMessage,
  }) {
    return _client.patch<CartData>(
      ApiEndpoints.cartGiftWrap,
      data: {
        'giftWrap': giftWrap,
        if (giftMessage != null) 'giftMessage': giftMessage,
      },
      fromJson: (data) => CartData.fromJson(data as Map<String, dynamic>),
    );
  }

  /// M35: Redeem loyalty points for discount
  Future<ApiResult<CartData>> redeemPoints(int points) {
    return _client.post<CartData>(
      ApiEndpoints.cartRedeemPoints,
      data: {'points': points},
      fromJson: (data) => CartData.fromJson(data as Map<String, dynamic>),
    );
  }

  /// M36: Recalculate summary breakdown
  Future<ApiResult<CartTotals>> getTotals() {
    return _client.get<CartTotals>(
      ApiEndpoints.cartTotals,
      fromJson: (data) => CartTotals.fromJson(data as Map<String, dynamic>),
    );
  }
}
