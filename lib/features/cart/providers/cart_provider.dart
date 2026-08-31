import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:sfa/core/models/product.dart';

import '../models/cart_item.dart';

class CartNotifier extends Notifier<List<CartItem>> {
  @override
  List<CartItem> build() => [];

  /// Adds a line for the given product/color/size, or bumps its quantity
  /// by one if that exact combination is already in the cart.
  void addItem({
    required Product product,
    required Color color,
    required String size,
  }) {
    final id = CartItem.keyFor(title: product.title, color: color, size: size);
    final index = state.indexWhere((item) => item.id == id);

    if (index != -1) {
      final updated = [...state];
      updated[index] = updated[index].copyWith(
        quantity: updated[index].quantity + 1,
      );
      state = updated;
    } else {
      state = [
        ...state,
        CartItem(
          id: id,
          imageUrl: product.imageUrl,
          brand: product.brandName ?? '',
          title: product.title,
          price: product.price,
          color: color,
          size: size,
        ),
      ];
    }
  }

  void removeItem(String id) {
    state = state.where((item) => item.id != id).toList();
  }
}

final cartProvider = NotifierProvider<CartNotifier, List<CartItem>>(
  CartNotifier.new,
);

/// Total item count for the cart badge shown in every app bar — sums
/// quantities rather than counting lines, so "2x of the same item" reads
/// as 2, not 1.
final cartItemCountProvider = Provider<int>((ref) {
  return ref
      .watch(cartProvider)
      .fold<int>(0, (sum, item) => sum + item.quantity);
});

/// Sum of `quantity * unit price`, parsed out of the same formatted price
/// strings the rest of the app displays (e.g. "1,250 SAR" / "1,250 ر.س.").
double cartSubtotal(List<CartItem> items) {
  return items.fold<double>(0, (sum, item) {
    final numeric = item.price.replaceAll(RegExp(r'[^0-9.]'), '');
    final value = double.tryParse(numeric) ?? 0;
    return sum + value * item.quantity;
  });
}

final cartSubtotalProvider = Provider<double>((ref) {
  return cartSubtotal(ref.watch(cartProvider));
});

/// Renders an amount back into the same "1,250 SAR" / "1,250 ر.س." shape
/// used throughout the mock product data.
String formatCartPrice(double amount, bool isArabic) {
  final formatted = NumberFormat('#,##0').format(amount);
  return isArabic ? '$formatted ر.س.' : '$formatted SAR';
}
