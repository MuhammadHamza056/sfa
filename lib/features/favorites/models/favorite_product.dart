class FavoriteProduct {
  final String title;
  final String imageUrl;
  final String price;
  final String rating;

  FavoriteProduct({
    required this.title,
    required this.imageUrl,
    required this.price,
    required this.rating,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'imageUrl': imageUrl,
        'price': price,
        'rating': rating,
      };

  factory FavoriteProduct.fromJson(Map<String, dynamic> json) => FavoriteProduct(
        title: json['title'] ?? '',
        imageUrl: json['imageUrl'] ?? '',
        price: json['price'] ?? '',
        rating: json['rating'] ?? '',
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FavoriteProduct &&
          runtimeType == other.runtimeType &&
          title == other.title;

  @override
  int get hashCode => title.hashCode;
}
