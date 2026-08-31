import 'package:flutter_riverpod/flutter_riverpod.dart';

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

/// Replaces the old per-screen `CheckoutBloc`. `.autoDispose` reproduces the
/// same lifecycle — a fresh selection every time the checkout screen is
/// pushed.
class CheckoutNotifier extends AutoDisposeNotifier<CheckoutState> {
  @override
  CheckoutState build() => const CheckoutState();

  void changeBottomNavIndex(int index) {
    state = state.copyWith(bottomNavIndex: index);
  }

  void changeRegionIndex(int index) {
    state = state.copyWith(selectedRegionIndex: index);
  }

  void changePayment(String paymentOption) {
    state = state.copyWith(selectedPayment: paymentOption);
  }
}

final checkoutProvider =
    NotifierProvider.autoDispose<CheckoutNotifier, CheckoutState>(
      CheckoutNotifier.new,
    );
