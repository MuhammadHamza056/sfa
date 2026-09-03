import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_result.dart';
import 'catalog_models.dart';

/// M12-M26 from the guide: home feed, categories, search, products and
/// brands. List endpoints aren't fully specified in the guide (some are
/// plainly paginated like `/products`, others read as flat arrays like
/// `/categories`), so [_asList] accepts either a raw JSON array or a
/// `{ items: [...] }` wrapper for anything not explicitly paginated.
class CatalogRepository {
  CatalogRepository(this._client);

  final ApiClient _client;

  static List<T> _asList<T>(
    dynamic data,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final raw = data is Map<String, dynamic> && data['items'] is List
        ? data['items'] as List
        : (data is List ? data : const []);
    return raw.map((v) => fromJson(v as Map<String, dynamic>)).toList();
  }

  /// M12: Aggregated SAFA home screen feed
  Future<ApiResult<HomeFeedData>> getHomeFeed() {
    return _client.get<HomeFeedData>(
      ApiEndpoints.homeFeed,
      fromJson: (data) => HomeFeedData.fromJson(data as Map<String, dynamic>),
    );
  }

  /// M13: List all root product categories
  Future<ApiResult<List<CatalogCategory>>> getCategories() {
    return _client.get<List<CatalogCategory>>(
      ApiEndpoints.categories,
      fromJson: (data) => _asList(data, CatalogCategory.fromJson),
    );
  }

  /// M14: Category details & subcategories
  Future<ApiResult<CatalogCategory>> getCategory(String id) {
    return _client.get<CatalogCategory>(
      ApiEndpoints.categoryDetail(id),
      fromJson: (data) => CatalogCategory.fromJson(data as Map<String, dynamic>),
    );
  }

  /// M15: Global search across products & brands
  Future<ApiResult<SearchResults>> search({
    required String query,
    String? categoryId,
    int? minPrice,
    int? maxPrice,
    int page = 1,
    int limit = 20,
  }) {
    return _client.get<SearchResults>(
      ApiEndpoints.search,
      queryParameters: {
        'q': query,
        if (categoryId != null) 'categoryId': categoryId,
        if (minPrice != null) 'minPrice': minPrice,
        if (maxPrice != null) 'maxPrice': maxPrice,
        'page': page,
        'limit': limit,
      },
      fromJson: (data) => SearchResults.fromJson(data as Map<String, dynamic>),
    );
  }

  /// M16: Filterable & paginated product catalog
  Future<ApiResult<ProductSearchPage>> getProducts({
    String? categoryId,
    String? brandId,
    int? minPrice,
    int? maxPrice,
    int page = 1,
    int limit = 20,
  }) {
    return _client.get<ProductSearchPage>(
      ApiEndpoints.products,
      queryParameters: {
        if (categoryId != null) 'categoryId': categoryId,
        if (brandId != null) 'brandId': brandId,
        if (minPrice != null) 'minPrice': minPrice,
        if (maxPrice != null) 'maxPrice': maxPrice,
        'page': page,
        'limit': limit,
      },
      fromJson: (data) {
        if (data is Map<String, dynamic> && data.containsKey('items')) {
          return ProductSearchPage.fromJson(data);
        }
        final items = _asList(data, CatalogProduct.fromJson);
        return ProductSearchPage(
          items: items,
          total: items.length,
          page: 1,
          totalPages: 1,
        );
      },
    );
  }

  /// M17: Product detail, options, addons & stock
  Future<ApiResult<CatalogProduct>> getProductDetail(String id) {
    return _client.get<CatalogProduct>(
      ApiEndpoints.productDetail(id),
      fromJson: (data) => CatalogProduct.fromJson(data as Map<String, dynamic>),
    );
  }

  /// M18: Related products recommendation
  Future<ApiResult<List<CatalogProduct>>> getRelatedProducts(String id) {
    return _client.get<List<CatalogProduct>>(
      ApiEndpoints.relatedProducts(id),
      fromJson: (data) => _asList(data, CatalogProduct.fromJson),
    );
  }

  /// M17: Colors, sizes & variant availability — the product detail
  /// response (M16) already embeds `options`/`addons`/`stock` inline, so
  /// this is only needed if a screen wants variants without the rest of
  /// the product payload.
  Future<ApiResult<List<CatalogProductOption>>> getProductVariants(String id) {
    return _client.get<List<CatalogProductOption>>(
      ApiEndpoints.productVariants(id),
      fromJson: (data) => _asList(data, CatalogProductOption.fromJson),
    );
  }

  /// M18: Product stock & availability status
  Future<ApiResult<Map<String, dynamic>>> getProductStock(String id) {
    return _client.get<Map<String, dynamic>>(
      ApiEndpoints.productStock(id),
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }

  /// M20: Search products and brands catalog (distinct from M15's
  /// `/search`, which spans products+brands together).
  Future<ApiResult<ProductSearchPage>> searchProducts({
    required String query,
    int page = 1,
    int limit = 20,
  }) {
    return _client.get<ProductSearchPage>(
      ApiEndpoints.productSearch,
      queryParameters: {'q': query, 'page': page, 'limit': limit},
      fromJson: (data) {
        if (data is Map<String, dynamic> && data.containsKey('items')) {
          return ProductSearchPage.fromJson(data);
        }
        final items = _asList(data, CatalogProduct.fromJson);
        return ProductSearchPage(items: items, total: items.length, page: 1, totalPages: 1);
      },
    );
  }

  /// M21: Catalog filter facets (price ranges, categories, brands)
  Future<ApiResult<Map<String, dynamic>>> getProductFilters() {
    return _client.get<Map<String, dynamic>>(
      ApiEndpoints.productFilters,
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }

  /// M22: Directory of verified Saudi brands
  Future<ApiResult<List<CatalogBrand>>> getBrands() {
    return _client.get<List<CatalogBrand>>(
      ApiEndpoints.brands,
      fromJson: (data) => _asList(data, CatalogBrand.fromJson),
    );
  }

  /// Categories with active brand/product counts, for the Brands tab's
  /// category chip row.
  Future<ApiResult<List<BrandCategory>>> getBrandCategories() {
    return _client.get<List<BrandCategory>>(
      ApiEndpoints.brandCategories,
      fromJson: (data) => _asList(data, BrandCategory.fromJson),
    );
  }

  /// Brands filtered by a single category id or slug (Brands tab category
  /// chips, as opposed to M22's unfiltered directory).
  Future<ApiResult<List<CatalogBrand>>> getBrandsByCategory(String categoryId) {
    return _client.get<List<CatalogBrand>>(
      ApiEndpoints.brandsByCategory(categoryId),
      fromJson: (data) => _asList(data, CatalogBrand.fromJson),
    );
  }

  /// M23: Brand profile & brand story
  Future<ApiResult<CatalogBrand>> getBrand(String id) {
    return _client.get<CatalogBrand>(
      ApiEndpoints.brandDetail(id),
      fromJson: (data) => CatalogBrand.fromJson(data as Map<String, dynamic>),
    );
  }

  /// M24: Brand products catalog
  Future<ApiResult<List<CatalogProduct>>> getBrandProducts(
    String brandId, {
    int page = 1,
    int limit = 20,
  }) {
    return _client.get<List<CatalogProduct>>(
      ApiEndpoints.brandProducts(brandId),
      queryParameters: {'page': page, 'limit': limit},
      fromJson: (data) => _asList(data, CatalogProduct.fromJson),
    );
  }

  /// M14: Category promotional banners. Replaces the old standalone
  /// `/banners` path, which the revised guide dropped — the home feed
  /// (M12) still has its own `banners` array for the hero carousel; this
  /// one is specifically the category-banners section.
  Future<ApiResult<List<CatalogBanner>>> getCategoryBanners() {
    return _client.get<List<CatalogBanner>>(
      ApiEndpoints.categoryBanners,
      fromJson: (data) => _asList(data, CatalogBanner.fromJson),
    );
  }

  /// M25: Static CMS pages
  Future<ApiResult<Map<String, dynamic>>> _getContentPage(String path) {
    return _client.get<Map<String, dynamic>>(path, fromJson: (data) => data as Map<String, dynamic>);
  }

  Future<ApiResult<Map<String, dynamic>>> getDeliveryTerms() =>
      _getContentPage(ApiEndpoints.contentDeliveryTerms);
  Future<ApiResult<Map<String, dynamic>>> getAboutPage() =>
      _getContentPage(ApiEndpoints.contentAbout);
  Future<ApiResult<Map<String, dynamic>>> getTermsPage() =>
      _getContentPage(ApiEndpoints.contentTerms);
  Future<ApiResult<Map<String, dynamic>>> getFaqPage() =>
      _getContentPage(ApiEndpoints.contentFaq);
  Future<ApiResult<Map<String, dynamic>>> getContactPage() =>
      _getContentPage(ApiEndpoints.contentContact);
}
