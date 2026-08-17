import 'package:flutter/foundation.dart';

@immutable
class OrderTrackingState {
  final int bottomNavIndex;

  const OrderTrackingState({this.bottomNavIndex = 0});

  OrderTrackingState copyWith({int? bottomNavIndex}) {
    return OrderTrackingState(
      bottomNavIndex: bottomNavIndex ?? this.bottomNavIndex,
    );
  }
}
