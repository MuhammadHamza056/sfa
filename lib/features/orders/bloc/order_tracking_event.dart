import 'package:flutter/foundation.dart';

@immutable
abstract class OrderTrackingEvent {
  const OrderTrackingEvent();
}

class ChangeBottomNavIndexEvent extends OrderTrackingEvent {
  final int index;
  const ChangeBottomNavIndexEvent(this.index);
}
