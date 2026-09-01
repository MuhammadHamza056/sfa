import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_result.dart';
import 'wishlist_models.dart';

/// M85-M91 from the guide.
class WishlistsRepository {
  WishlistsRepository(this._client);

  final ApiClient _client;

  /// M85: Customer wishlists collections
  Future<ApiResult<List<WishlistSummary>>> getWishlists() {
    return _client.get<List<WishlistSummary>>(
      ApiEndpoints.wishlists,
      fromJson: (data) {
        final raw = data is Map<String, dynamic> && data['items'] is List
            ? data['items'] as List
            : (data is List ? data : const []);
        return raw.map((v) => WishlistSummary.fromJson(v as Map<String, dynamic>)).toList();
      },
    );
  }

  /// M86: Create new wishlist. Matches the guide's request example exactly
  /// — body key is `name`, not `title`.
  Future<ApiResult<WishlistSummary>> createWishlist(String name) {
    return _client.post<WishlistSummary>(
      ApiEndpoints.wishlists,
      data: {'name': name},
      fromJson: (data) => WishlistSummary.fromJson(data as Map<String, dynamic>),
    );
  }

  /// M87: Wishlist items & details
  Future<ApiResult<WishlistDetail>> getWishlist(String id) {
    return _client.get<WishlistDetail>(
      ApiEndpoints.wishlistDetail(id),
      fromJson: (data) => WishlistDetail.fromJson(data as Map<String, dynamic>),
    );
  }

  /// M88: Add product to wishlist. Matches the guide's request example
  /// exactly — body key is `productId`, not `itemId` (unlike cart items).
  /// `selectedSize`/`selectedColor` aren't in the guide's minimal example;
  /// kept as optional extras in case the backend still accepts them.
  Future<ApiResult<void>> addItem(
    String wishlistId, {
    required String productId,
    String? selectedSize,
    String? selectedColor,
  }) {
    return _client.post<void>(
      ApiEndpoints.wishlistItems(wishlistId),
      data: {
        'productId': productId,
        if (selectedSize != null) 'selectedSize': selectedSize,
        if (selectedColor != null) 'selectedColor': selectedColor,
      },
      fromJson: (_) {},
    );
  }

  /// M89: Remove item from wishlist
  Future<ApiResult<void>> removeItem(String wishlistId, String productId) {
    return _client.delete<void>(
      ApiEndpoints.wishlistItemDetail(wishlistId, productId),
      fromJson: (_) {},
    );
  }

  /// M90: Generate share token
  Future<ApiResult<WishlistShareResult>> getShareLink(String id) {
    return _client.get<WishlistShareResult>(
      ApiEndpoints.wishlistShare(id),
      fromJson: (data) => WishlistShareResult.fromJson(data as Map<String, dynamic>),
    );
  }

  /// M91: View public shared wishlist
  Future<ApiResult<WishlistDetail>> getSharedWishlist(String token) {
    return _client.get<WishlistDetail>(
      ApiEndpoints.wishlistShared(token),
      fromJson: (data) => WishlistDetail.fromJson(data as Map<String, dynamic>),
    );
  }
}
