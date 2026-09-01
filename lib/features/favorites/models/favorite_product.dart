class FavoriteProduct {
  final String productId;
  final String title;
  final String imageUrl;
  final String price;
  final String rating;
  final String? brandName;

  FavoriteProduct({
    required this.productId,
    required this.title,
    required this.imageUrl,
    required this.price,
    this.rating = '',
    this.brandName,
  });

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'title': title,
        'imageUrl': imageUrl,
        'price': price,
        'rating': rating,
        'brandName': brandName,
      };

  factory FavoriteProduct.fromJson(Map<String, dynamic> json) => FavoriteProduct(
        productId: json['productId'] ?? '',
        title: json['title'] ?? '',
        imageUrl: json['imageUrl'] ?? '',
        price: json['price'] ?? '',
        rating: json['rating'] ?? '',
        brandName: json['brandName'],
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FavoriteProduct &&
          runtimeType == other.runtimeType &&
          productId == other.productId;

  @override
  int get hashCode => productId.hashCode;
}
