import 'package:flutter/foundation.dart';

@immutable
abstract class BrandsEvent {
  const BrandsEvent();
}

class ChangeGenderEvent extends BrandsEvent {
  final int genderIndex;
  const ChangeGenderEvent(this.genderIndex);
}

class ChangeCategoryEvent extends BrandsEvent {
  final int categoryIndex;
  const ChangeCategoryEvent(this.categoryIndex);
}
