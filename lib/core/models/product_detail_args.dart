class ProductDetailArgs {
  /// The API product id. When present, the detail screen fetches the full
  /// record (`GET /products/:id`) instead of relying only on these fields.
  final String? id;

  final String name;
  final String imageUrl;
  final String price;
  final String rating;
  final String? brandNameKey;

  const ProductDetailArgs({
    this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.rating,
    this.brandNameKey,
  });
}
