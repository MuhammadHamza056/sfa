import 'package:flutter/foundation.dart';

@immutable
class CheckoutState {
  final int bottomNavIndex;
  final int selectedRegionIndex;
  final String selectedPayment;

  const CheckoutState({
    this.bottomNavIndex = 0,
    this.selectedRegionIndex = 0,
    this.selectedPayment = 'PayTaps',
  });

  CheckoutState copyWith({
    int? bottomNavIndex,
    int? selectedRegionIndex,
    String? selectedPayment,
  }) {
    return CheckoutState(
      bottomNavIndex: bottomNavIndex ?? this.bottomNavIndex,
      selectedRegionIndex: selectedRegionIndex ?? this.selectedRegionIndex,
      selectedPayment: selectedPayment ?? this.selectedPayment,
    );
  }
}
