class ProductDetailArgs {
  final String name;
  final String imageUrl;
  final String price;
  final String rating;
  final String? brandNameKey;

  const ProductDetailArgs({
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.rating,
    this.brandNameKey,
  });
}
