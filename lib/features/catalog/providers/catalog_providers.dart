import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../data/catalog_models.dart';
import '../data/catalog_repository.dart';

final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  return CatalogRepository(ApiClient.instance);
});

/// Every provider below hands back the raw bilingual `Catalog*` models
/// (never a pre-resolved display string), so a language toggle never has to
/// refetch — screens call `.resolve(isAr)` / `.toProduct(isAr)` at render
/// time instead.

/// M12
final homeFeedProvider = FutureProvider<HomeFeedData>((ref) async {
  final result = await ref.read(catalogRepositoryProvider).getHomeFeed();
  return result.when(success: (data) => data, failure: (e) => throw e);
});

/// M13
final categoriesProvider = FutureProvider<List<CatalogCategory>>((ref) async {
  final result = await ref.read(catalogRepositoryProvider).getCategories();
  return result.when(success: (data) => data, failure: (e) => throw e);
});

/// M17 — keyed by product id. Named `catalogProductDetailProvider` (not
/// `productDetailProvider`) because that name is already taken by the
/// UI-selection-state notifier in `features/brands/providers/product_detail_provider.dart`.
final catalogProductDetailProvider = FutureProvider.family<CatalogProduct, String>((
  ref,
  id,
) async {
  final result = await ref.read(catalogRepositoryProvider).getProductDetail(id);
  return result.when(success: (data) => data, failure: (e) => throw e);
});

/// M18 — keyed by product id.
final relatedProductsProvider = FutureProvider.family<List<CatalogProduct>, String>(
  (ref, id) async {
    final result =
        await ref.read(catalogRepositoryProvider).getRelatedProducts(id);
    return result.when(success: (data) => data, failure: (e) => throw e);
  },
);

/// The revised guide dropped the dedicated `/products/featured` endpoint —
/// this now filters the general catalog (M15) by category instead. Keyed
/// by category id (empty string = no filter).
final featuredProductsProvider =
    FutureProvider.family<List<CatalogProduct>, String>((ref, categoryId) async {
  final result = await ref
      .read(catalogRepositoryProvider)
      .getProducts(categoryId: categoryId.isEmpty ? null : categoryId, limit: 20);
  return result.when(success: (page) => page.items, failure: (e) => throw e);
});

/// M22
final brandsListProvider = FutureProvider<List<CatalogBrand>>((ref) async {
  final result = await ref.read(catalogRepositoryProvider).getBrands();
  return result.when(success: (data) => data, failure: (e) => throw e);
});

/// M23 — keyed by brand id.
final brandDetailProvider = FutureProvider.family<CatalogBrand, String>((
  ref,
  id,
) async {
  final result = await ref.read(catalogRepositoryProvider).getBrand(id);
  return result.when(success: (data) => data, failure: (e) => throw e);
});

/// M24 — keyed by brand id.
final brandProductsProvider =
    FutureProvider.family<List<CatalogProduct>, String>((ref, brandId) async {
  final result =
      await ref.read(catalogRepositoryProvider).getBrandProducts(brandId);
  return result.when(success: (data) => data, failure: (e) => throw e);
});

/// M14
final bannersProvider = FutureProvider<List<CatalogBanner>>((ref) async {
  final result = await ref.read(catalogRepositoryProvider).getCategoryBanners();
  return result.when(success: (data) => data, failure: (e) => throw e);
});

/// M15 — keyed by the raw query string; empty query short-circuits to an
/// empty result so the search screen doesn't fire a request per keystroke
/// before the user has typed anything.
final searchProvider = FutureProvider.family<SearchResults, String>((
  ref,
  query,
) async {
  if (query.trim().isEmpty) {
    return const SearchResults(
      products: ProductSearchPage(items: [], total: 0, page: 1, totalPages: 1),
      brands: [],
    );
  }
  final result =
      await ref.read(catalogRepositoryProvider).search(query: query.trim());
  return result.when(success: (data) => data, failure: (e) => throw e);
});
