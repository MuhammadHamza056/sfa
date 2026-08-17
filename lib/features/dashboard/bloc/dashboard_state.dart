import 'package:flutter/foundation.dart';

@immutable
class DashboardState {
  final bool drawerOpen;
  final int currentIndex;
  final int previousIndex;
  final String? selectedBrandName;
  final String? selectedProductName;
  final String? selectedProductImage;
  final String? selectedProductPrice;
  final String? selectedProductRating;

  const DashboardState({
    this.drawerOpen = false,
    this.currentIndex = 0,
    this.previousIndex = 0,
    this.selectedBrandName,
    this.selectedProductName,
    this.selectedProductImage,
    this.selectedProductPrice,
    this.selectedProductRating,
  });

  DashboardState copyWith({
    bool? drawerOpen,
    int? currentIndex,
    int? previousIndex,
    String? selectedBrandName,
    String? selectedProductName,
    String? selectedProductImage,
    String? selectedProductPrice,
    String? selectedProductRating,
  }) {
    return DashboardState(
      drawerOpen: drawerOpen ?? this.drawerOpen,
      currentIndex: currentIndex ?? this.currentIndex,
      previousIndex: previousIndex ?? this.previousIndex,
      selectedBrandName: selectedBrandName ?? this.selectedBrandName,
      selectedProductName: selectedProductName ?? this.selectedProductName,
      selectedProductImage: selectedProductImage ?? this.selectedProductImage,
      selectedProductPrice: selectedProductPrice ?? this.selectedProductPrice,
      selectedProductRating: selectedProductRating ?? this.selectedProductRating,
    );
  }
}
