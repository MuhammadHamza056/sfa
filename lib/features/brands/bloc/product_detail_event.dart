import 'package:flutter/foundation.dart';

@immutable
abstract class ProductDetailEvent {
  const ProductDetailEvent();
}

class SelectColorEvent extends ProductDetailEvent {
  final int index;
  const SelectColorEvent(this.index);
}

class SelectSizeEvent extends ProductDetailEvent {
  final int index;
  const SelectSizeEvent(this.index);
}

class SelectCityEvent extends ProductDetailEvent {
  final String city;
  const SelectCityEvent(this.city);
}
