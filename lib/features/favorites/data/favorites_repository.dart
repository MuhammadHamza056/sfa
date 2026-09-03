import '../../../core/localization/app_localizations.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_result.dart';
import '../../../utils/currency_formatter.dart';
import '../models/favorite_product.dart';

/// M82-M84 from the guide.
class FavoritesRepository {
  FavoritesRepository(this._client);

  final ApiClient _client;

  static FavoriteProduct _fromJson(Map<String, dynamic> json) {
    final isAr = localeNotifier.value.languageCode == 'ar';
    final name = json['name'];
    final title = name is Map<String, dynamic>
        ? (isAr ? name['ar'] : name['en'])?.toString() ?? ''
        : (json['name']?.toString() ?? '');
    final priceFils = (json['priceFils'] as num?)?.toInt();
    return FavoriteProduct(
      // The favorites list entry carries its own record id separately from
      // the product it points to (same shape as `WishlistItem` in
      // wishlist_models.dart) — `DELETE /favorites/{productId}` needs the
      // latter, so prefer `productId` over the entry's `id`.
      productId: (json['productId'] ?? json['itemId'] ?? json['id'])?.toString() ?? '',
      title: title,
      imageUrl: json['image']?.toString() ?? '',
      price: priceFils != null
          ? CurrencyFormatter.fromHalalas(priceFils, isAr: isAr)
          : (json['price']?.toString() ?? ''),
      brandName: json['brandName'] as String?,
    );
  }

  /// M82: Saved favorite products
  Future<ApiResult<List<FavoriteProduct>>> getFavorites() {
    return _client.get<List<FavoriteProduct>>(
      ApiEndpoints.favorites,
      fromJson: (data) {
        final raw = data is Map<String, dynamic> && data['items'] is List
            ? data['items'] as List
            : (data is List ? data : const []);
        return raw.map((v) => _fromJson(v as Map<String, dynamic>)).toList();
      },
    );
  }

  /// M83: Add product to favorites
  Future<ApiResult<void>> addFavorite(String productId) {
    return _client.post<void>(
      ApiEndpoints.favorites,
      data: {'productId': productId},
      fromJson: (_) {},
    );
  }

  /// M84: Remove product from favorites
  Future<ApiResult<void>> removeFavorite(String productId) {
    return _client.delete<void>(ApiEndpoints.favoriteDetail(productId), fromJson: (_) {});
  }
}
