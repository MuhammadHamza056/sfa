import 'package:flutter/foundation.dart';

@immutable
class OrdersState {
  // PreviousOrdersScreen States
  final int selectedTab;
  final bool isFirstCardExpanded;
  final bool isSecondCardExpanded;
  final bool isPrevFirstCardExpanded;
  final bool isPrevSecondCardExpanded;

  // RefundRequestScreen & RefundStatusScreen States
  final bool isProductsExpanded;
  final Map<String, bool> selectedProducts; // Product ID/Name to isSelected
  final String? selectedReason;

  const OrdersState({
    this.selectedTab = 0,
    this.isFirstCardExpanded = false,
    this.isSecondCardExpanded = true,
    this.isPrevFirstCardExpanded = false,
    this.isPrevSecondCardExpanded = true,
    this.isProductsExpanded = true,
    this.selectedProducts = const {},
    this.selectedReason,
  });

  OrdersState copyWith({
    int? selectedTab,
    bool? isFirstCardExpanded,
    bool? isSecondCardExpanded,
    bool? isPrevFirstCardExpanded,
    bool? isPrevSecondCardExpanded,
    bool? isProductsExpanded,
    Map<String, bool>? selectedProducts,
    String? selectedReason,
  }) {
    return OrdersState(
      selectedTab: selectedTab ?? this.selectedTab,
      isFirstCardExpanded: isFirstCardExpanded ?? this.isFirstCardExpanded,
      isSecondCardExpanded: isSecondCardExpanded ?? this.isSecondCardExpanded,
      isPrevFirstCardExpanded: isPrevFirstCardExpanded ?? this.isPrevFirstCardExpanded,
      isPrevSecondCardExpanded: isPrevSecondCardExpanded ?? this.isPrevSecondCardExpanded,
      isProductsExpanded: isProductsExpanded ?? this.isProductsExpanded,
      selectedProducts: selectedProducts ?? this.selectedProducts,
      selectedReason: selectedReason ?? this.selectedReason,
    );
  }
}
