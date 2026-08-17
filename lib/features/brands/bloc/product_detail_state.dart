import 'package:flutter/foundation.dart';

@immutable
class ProductDetailState {
  final int selectedColorIndex;
  final int selectedSizeIndex;
  final String selectedCity;

  const ProductDetailState({
    this.selectedColorIndex = 0,
    this.selectedSizeIndex = 0,
    this.selectedCity = 'cityRiyadh',
  });

  ProductDetailState copyWith({
    int? selectedColorIndex,
    int? selectedSizeIndex,
    String? selectedCity,
  }) {
    return ProductDetailState(
      selectedColorIndex: selectedColorIndex ?? this.selectedColorIndex,
      selectedSizeIndex: selectedSizeIndex ?? this.selectedSizeIndex,
      selectedCity: selectedCity ?? this.selectedCity,
    );
  }
}
