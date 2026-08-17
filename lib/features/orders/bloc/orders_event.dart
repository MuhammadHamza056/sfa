import 'package:flutter/foundation.dart';

@immutable
abstract class OrdersEvent {
  const OrdersEvent();
}

class ChangeOrdersTabEvent extends OrdersEvent {
  final int index;
  const ChangeOrdersTabEvent(this.index);
}

class ToggleFirstCardExpandedEvent extends OrdersEvent {
  const ToggleFirstCardExpandedEvent();
}

class ToggleSecondCardExpandedEvent extends OrdersEvent {
  const ToggleSecondCardExpandedEvent();
}

class TogglePrevFirstCardExpandedEvent extends OrdersEvent {
  const TogglePrevFirstCardExpandedEvent();
}

class TogglePrevSecondCardExpandedEvent extends OrdersEvent {
  const TogglePrevSecondCardExpandedEvent();
}

class ToggleProductsExpandedEvent extends OrdersEvent {
  const ToggleProductsExpandedEvent();
}

class ToggleProductSelectionEvent extends OrdersEvent {
  final String productId;
  final bool isSelected;
  const ToggleProductSelectionEvent(this.productId, this.isSelected);
}

class ChangeRefundReasonEvent extends OrdersEvent {
  final String? reason;
  const ChangeRefundReasonEvent(this.reason);
}
