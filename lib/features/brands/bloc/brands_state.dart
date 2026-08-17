import 'package:flutter/foundation.dart';

@immutable
class BrandsState {
  final int selectedGender;
  final int selectedCategory;

  const BrandsState({
    this.selectedGender = 0,
    this.selectedCategory = 0,
  });

  BrandsState copyWith({
    int? selectedGender,
    int? selectedCategory,
  }) {
    return BrandsState(
      selectedGender: selectedGender ?? this.selectedGender,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }
}
