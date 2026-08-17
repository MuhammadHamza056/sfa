import 'package:flutter/foundation.dart';

@immutable
abstract class HomeEvent {
  const HomeEvent();
}

class ChangeCategoryIndexEvent extends HomeEvent {
  final int index;
  const ChangeCategoryIndexEvent(this.index);
}

class ChangeFeaturedTabEvent extends HomeEvent {
  final int index;
  const ChangeFeaturedTabEvent(this.index);
}
