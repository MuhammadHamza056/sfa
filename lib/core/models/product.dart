import 'package:sfa/core/models/product_detail_args.dart';

/// Canonical product shape shared by every product grid/list in the app
/// (home featured products, brand detail, related products, ...).
class Product {
  /// The API product id (`M17` etc.). Null for screens still using static
  /// placeholder data.
  final String? id;

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
    this.id,
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
        id: id,
        name: title,
        imageUrl: imageUrl,
        price: price,
        rating: rating,
        brandNameKey: brandNameKey ?? brandName,
      );
}
