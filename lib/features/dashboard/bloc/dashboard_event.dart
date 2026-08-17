import 'package:flutter/foundation.dart';

@immutable
abstract class DashboardEvent {
  const DashboardEvent();
}

class SetDrawerOpenEvent extends DashboardEvent {
  final bool isOpen;
  const SetDrawerOpenEvent(this.isOpen);
}

class ChangeTabEvent extends DashboardEvent {
  final int index;
  const ChangeTabEvent(this.index);
}

class RestorePreviousTabEvent extends DashboardEvent {
  const RestorePreviousTabEvent();
}

class CacheCurrentTabEvent extends DashboardEvent {
  const CacheCurrentTabEvent();
}

class SelectBrandEvent extends DashboardEvent {
  final String brandName;
  const SelectBrandEvent(this.brandName);
}

class SelectProductEvent extends DashboardEvent {
  final String name;
  final String imageUrl;
  final String price;
  final String rating;
  const SelectProductEvent({
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.rating,
  });
}
