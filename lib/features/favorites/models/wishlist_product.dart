import 'package:flutter/material.dart';

class WishlistProduct {
  final String brand;
  final String name;
  final String price;
  final String imageUrl;
  final Color color;
  final String size;

  const WishlistProduct({
    required this.brand,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.color,
    required this.size,
  });
}
