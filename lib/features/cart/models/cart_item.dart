import 'package:flutter/material.dart';

class CartItem {
  /// Identifies one cart line — same product + color + size collapses into
  /// a single line with an incremented [quantity] instead of a duplicate row.
  final String id;
  final String imageUrl;
  final String brand;
  final String title;
  final String price;
  final Color color;
  final String size;
  final int quantity;
  final bool showWarning;

  const CartItem({
    required this.id,
    required this.imageUrl,
    required this.brand,
    required this.title,
    required this.price,
    required this.color,
    required this.size,
    this.quantity = 1,
    this.showWarning = false,
  });

  CartItem copyWith({int? quantity}) {
    return CartItem(
      id: id,
      imageUrl: imageUrl,
      brand: brand,
      title: title,
      price: price,
      color: color,
      size: size,
      quantity: quantity ?? this.quantity,
      showWarning: showWarning,
    );
  }

  static String keyFor({
    required String title,
    required Color color,
    required String size,
  }) => '$title|$color|$size';
}
