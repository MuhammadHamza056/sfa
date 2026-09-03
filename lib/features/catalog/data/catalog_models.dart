import '../../../core/models/localized_text.dart';
import '../../../core/models/product.dart';
import '../../../utils/currency_formatter.dart';

class CatalogBrandRef {
  final String id;
  final LocalizedText name;
  final String? logo;

  const CatalogBrandRef({required this.id, required this.name, this.logo});

  factory CatalogBrandRef.fromJson(Map<String, dynamic> json) {
    final localizedName = json['localizedName'];
    return CatalogBrandRef(
      id: json['_id']?.toString() ?? '',
      name: localizedName is Map<String, dynamic>
          ? LocalizedText.fromJson(localizedName)
          : LocalizedText.fromDynamic(json['name']),
      logo: (json['logo'] ?? json['vendorImageUrl']) as String?,
    );
  }
}

class CatalogProductVariant {
  final LocalizedText name;
  final String? sku;
  final int priceFils;
  final int stock;

  const CatalogProductVariant({
    required this.name,
    this.sku,
    required this.priceFils,
    required this.stock,
  });

  factory CatalogProductVariant.fromJson(Map<String, dynamic> json) {
    return CatalogProductVariant(
      name: LocalizedText.fromDynamic(json['name']),
      sku: json['sku'] as String?,
      priceFils: (json['priceFils'] as num?)?.toInt() ?? 0,
      stock: (json['stock'] as num?)?.toInt() ?? 0,
    );
  }
}

class CatalogProductOption {
  final String id;
  final LocalizedText name;
  final List<String> values;

  const CatalogProductOption({
    required this.id,
    required this.name,
    required this.values,
  });

  /// The guide's color option encodes each value as a hex string
  /// (`"#141D2B"`); everything else (size, ...) is a plain label chip.
  bool get isColorOption =>
      values.isNotEmpty && values.every((v) => v.startsWith('#'));

  factory CatalogProductOption.fromJson(Map<String, dynamic> json) {
    // Some endpoints send a flat `values: [String]`; the product-detail
    // shape instead sends `choices: [{name, priceDeltaFils, stock}]`.
    final choices = json['choices'] as List?;
    final values = json['values'] as List?;
    return CatalogProductOption(
      id: json['id']?.toString() ?? '',
      name: LocalizedText.fromDynamic(json['name']),
      values: choices != null
          ? choices
              .map((v) => (v as Map<String, dynamic>)['name']?.toString() ?? '')
              .toList()
          : (values ?? const []).map((v) => v.toString()).toList(),
    );
  }
}

class CatalogProductAddon {
  final String id;
  final LocalizedText name;
  final int priceFils;

  const CatalogProductAddon({
    required this.id,
    required this.name,
    required this.priceFils,
  });

  factory CatalogProductAddon.fromJson(Map<String, dynamic> json) {
    return CatalogProductAddon(
      id: json['id']?.toString() ?? '',
      name: LocalizedText.fromDynamic(json['name']),
      priceFils: (json['priceFils'] as num?)?.toInt() ?? 0,
    );
  }
}

/// The full product record from `GET /products/:id` (M17). List endpoints
/// (M16, M18-M21, M24) return the same shape minus `options`/`addons`/
/// `description`, which default safely to empty here.
class CatalogProduct {
  final String id;
  final LocalizedText name;
  final LocalizedText? description;
  final int priceFils;
  final int? oldPriceFils;
  final String currency;
  final String? sku;
  final List<String> images;
  final CatalogBrandRef? brand;
  final List<CatalogProductOption> options;
  final List<CatalogProductAddon> addons;
  final List<CatalogProductVariant> variants;
  final int stock;
  final bool isAvailable;
  final double avgRating;
  final int reviewCount;

  const CatalogProduct({
    required this.id,
    required this.name,
    this.description,
    required this.priceFils,
    this.oldPriceFils,
    this.currency = 'SAR',
    this.sku,
    required this.images,
    this.brand,
    this.options = const [],
    this.addons = const [],
    this.variants = const [],
    this.stock = 0,
    this.isAvailable = true,
    this.avgRating = 0,
    this.reviewCount = 0,
  });

  factory CatalogProduct.fromJson(Map<String, dynamic> json) {
    final vendorJson = json['vendorId'] ?? json['brand'];
    return CatalogProduct(
      id: json['_id']?.toString() ?? '',
      name: LocalizedText.fromDynamic(json['name']),
      description: json['description'] != null
          ? LocalizedText.fromDynamic(json['description'])
          : null,
      priceFils: (json['priceFils'] as num?)?.toInt() ?? 0,
      oldPriceFils: (json['oldPriceFils'] as num?)?.toInt(),
      currency: json['currency'] as String? ?? 'SAR',
      sku: json['sku'] as String?,
      images: (json['images'] as List? ?? const [])
          .map((v) => v.toString())
          .toList(),
      brand: vendorJson is Map<String, dynamic>
          ? CatalogBrandRef.fromJson(vendorJson)
          : null,
      options: (json['options'] as List? ?? const [])
          .map((v) => CatalogProductOption.fromJson(v as Map<String, dynamic>))
          .toList(),
      addons: (json['addons'] as List? ?? const [])
          .map((v) => CatalogProductAddon.fromJson(v as Map<String, dynamic>))
          .toList(),
      variants: (json['variants'] as List? ?? const [])
          .map((v) => CatalogProductVariant.fromJson(v as Map<String, dynamic>))
          .toList(),
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      isAvailable: json['isActive'] as bool? ?? true,
      avgRating: (json['rating'] as num?)?.toDouble() ?? 0,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
    );
  }

  Product toProduct(bool isAr) {
    return Product(
      id: id,
      imageUrl: images.isNotEmpty ? images.first : '',
      title: name.resolve(isAr),
      price: CurrencyFormatter.fromHalalas(priceFils, isAr: isAr),
      rating: avgRating.toStringAsFixed(1),
      brandName: brand?.name.resolve(isAr),
      reviewsLabel: reviewCount > 0
          ? (isAr ? '$reviewCount تقييمًا' : '$reviewCount reviews')
          : null,
    );
  }
}

class CatalogCategory {
  final String id;
  final LocalizedText name;
  final String? iconUrl;

  const CatalogCategory({required this.id, required this.name, this.iconUrl});

  factory CatalogCategory.fromJson(Map<String, dynamic> json) {
    return CatalogCategory(
      id: json['_id']?.toString() ?? '',
      name: LocalizedText.fromDynamic(json['name']),
      iconUrl: json['icon'] as String?,
    );
  }
}

/// A category as returned by `/brands/categories`, used to drive the Brands
/// tab's category chip row — distinct from [CatalogCategory] (`/categories`)
/// since this one carries brand/product counts for that specific screen.
class BrandCategory {
  final String id;
  final LocalizedText name;
  final String slug;
  final String? iconUrl;
  final int brandCount;
  final int productCount;

  const BrandCategory({
    required this.id,
    required this.name,
    required this.slug,
    this.iconUrl,
    this.brandCount = 0,
    this.productCount = 0,
  });

  factory BrandCategory.fromJson(Map<String, dynamic> json) {
    return BrandCategory(
      id: json['_id']?.toString() ?? '',
      name: LocalizedText.fromDynamic(json['name']),
      slug: json['slug']?.toString() ?? '',
      iconUrl: json['icon'] as String?,
      brandCount: (json['brandCount'] as num?)?.toInt() ?? 0,
      productCount: (json['productCount'] as num?)?.toInt() ?? 0,
    );
  }
}

class CatalogBrand {
  final String id;
  final LocalizedText name;
  final String? logo;
  final String businessStatus;
  final double rating;
  final int reviewCount;
  final LocalizedText? story;

  const CatalogBrand({
    required this.id,
    required this.name,
    this.logo,
    this.businessStatus = '',
    this.rating = 0,
    this.reviewCount = 0,
    this.story,
  });

  bool get isOpen => businessStatus == 'OPEN';

  factory CatalogBrand.fromJson(Map<String, dynamic> json) {
    return CatalogBrand(
      id: json['_id']?.toString() ?? '',
      name: LocalizedText.fromDynamic(json['name']),
      logo: json['logo'] as String?,
      businessStatus: json['businessStatus'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
      story: json['story'] != null
          ? LocalizedText.fromDynamic(json['story'])
          : null,
    );
  }
}

class CatalogBanner {
  final String id;
  final LocalizedText title;
  final String imageUrl;
  final String? linkType;
  final String? linkId;

  const CatalogBanner({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.linkType,
    this.linkId,
  });

  factory CatalogBanner.fromJson(Map<String, dynamic> json) {
    return CatalogBanner(
      id: (json['_id'] ?? json['id'])?.toString() ?? '',
      title: LocalizedText.fromDynamic(json['title']),
      imageUrl: (json['image'] ?? json['imageUrl'])?.toString() ?? '',
      linkType: json['linkType'] as String?,
      linkId: json['linkId']?.toString(),
    );
  }
}

class HomeReel {
  final String id;
  final String videoUrl;
  final String thumbnailUrl;
  final int likesCount;

  const HomeReel({
    required this.id,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.likesCount,
  });

  factory HomeReel.fromJson(Map<String, dynamic> json) {
    return HomeReel(
      id: (json['_id'] ?? json['id'])?.toString() ?? '',
      videoUrl: json['videoUrl']?.toString() ?? '',
      thumbnailUrl: json['thumbnailUrl']?.toString() ?? '',
      likesCount: (json['likesCount'] as num?)?.toInt() ?? 0,
    );
  }
}

/// M12 — the whole `GET /home/feed` payload.
class HomeFeedData {
  final List<CatalogBanner> banners;
  final List<CatalogCategory> categories;
  final List<CatalogBrand> brands;
  final List<CatalogProduct> featuredProducts;
  final List<HomeReel> reels;

  const HomeFeedData({
    required this.banners,
    required this.categories,
    required this.brands,
    required this.featuredProducts,
    required this.reels,
  });

  factory HomeFeedData.fromJson(Map<String, dynamic> json) {
    List<T> list<T>(String key, T Function(Map<String, dynamic>) fromJson) {
      return (json[key] as List? ?? const [])
          .map((v) => fromJson(v as Map<String, dynamic>))
          .toList();
    }

    return HomeFeedData(
      banners: list('banners', CatalogBanner.fromJson),
      categories: list('categories', CatalogCategory.fromJson),
      brands: list('brands', CatalogBrand.fromJson),
      featuredProducts: list('featuredProducts', CatalogProduct.fromJson),
      reels: list('reels', HomeReel.fromJson),
    );
  }
}

class ProductSearchPage {
  final List<CatalogProduct> items;
  final int total;
  final int page;
  final int totalPages;

  const ProductSearchPage({
    required this.items,
    required this.total,
    required this.page,
    required this.totalPages,
  });

  factory ProductSearchPage.fromJson(Map<String, dynamic> json) {
    return ProductSearchPage(
      items: (json['items'] as List? ?? const [])
          .map((v) => CatalogProduct.fromJson(v as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num?)?.toInt() ?? 0,
      page: (json['page'] as num?)?.toInt() ?? 1,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 1,
    );
  }
}

class SearchResults {
  final ProductSearchPage products;
  final List<CatalogBrand> brands;

  const SearchResults({required this.products, required this.brands});

  factory SearchResults.fromJson(Map<String, dynamic> json) {
    return SearchResults(
      products: ProductSearchPage.fromJson(
        json['products'] as Map<String, dynamic>? ?? const {},
      ),
      brands: (((json['brands'] as Map<String, dynamic>?)?['items']) as List? ?? const [])
          .map((v) => CatalogBrand.fromJson(v as Map<String, dynamic>))
          .toList(),
    );
  }
}
