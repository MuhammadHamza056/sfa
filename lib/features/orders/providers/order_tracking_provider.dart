import 'package:flutter_riverpod/flutter_riverpod.dart';

class OrderTrackingState {
  final int bottomNavIndex;

  const OrderTrackingState({this.bottomNavIndex = 0});

  OrderTrackingState copyWith({int? bottomNavIndex}) {
    return OrderTrackingState(
      bottomNavIndex: bottomNavIndex ?? this.bottomNavIndex,
    );
  }
}

/// Replaces the old per-screen `OrderTrackingBloc`. `.autoDispose`
/// reproduces the same lifecycle — a fresh state every time the order
/// tracking screen is pushed.
class OrderTrackingNotifier extends AutoDisposeNotifier<OrderTrackingState> {
  @override
  OrderTrackingState build() => const OrderTrackingState();

  void changeBottomNavIndex(int index) {
    state = state.copyWith(bottomNavIndex: index);
  }
}

final orderTrackingProvider =
    NotifierProvider.autoDispose<OrderTrackingNotifier, OrderTrackingState>(
      OrderTrackingNotifier.new,
    );
