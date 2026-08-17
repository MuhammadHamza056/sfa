import 'package:flutter/foundation.dart';

@immutable
abstract class CheckoutEvent {
  const CheckoutEvent();
}

class ChangeBottomNavIndexEvent extends CheckoutEvent {
  final int index;
  const ChangeBottomNavIndexEvent(this.index);
}

class ChangeRegionIndexEvent extends CheckoutEvent {
  final int index;
  const ChangeRegionIndexEvent(this.index);
}

class ChangePaymentEvent extends CheckoutEvent {
  final String paymentOption;
  const ChangePaymentEvent(this.paymentOption);
}
