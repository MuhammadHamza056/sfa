import 'package:sfa/core/models/product_detail_args.dart';

/// Canonical product shape shared by every product grid/list in the app
/// (home featured products, brand detail, related products, ...).
class Product {
  final String imageUrl;
  final String title;
  final String price;
  final String rating;

  /// Shown above the title when set (e.g. "Juba"). Left null on screens
  /// where the brand is implied by the surrounding page instead (brand
  /// detail's own product grid).
  final String? brandName;

  /// Shown next to the rating when set (e.g. "85 reviews").
  final String? reviewsLabel;

  const Product({
    required this.imageUrl,
    required this.title,
    required this.price,
    required this.rating,
    this.brandName,
    this.reviewsLabel,
  });

  /// Args for the `/product-detail` route. [brandNameKey] overrides
  /// [brandName] for screens that know the brand from page context rather
  /// than from the product itself.
  ProductDetailArgs toDetailArgs({String? brandNameKey}) => ProductDetailArgs(
        name: title,
        imageUrl: imageUrl,
        price: price,
        rating: rating,
        brandNameKey: brandNameKey ?? brandName,
      );
}
