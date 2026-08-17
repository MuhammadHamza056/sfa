import 'package:flutter/foundation.dart';
import '../models/favorite_product.dart';

@immutable
abstract class FavoritesEvent {
  const FavoritesEvent();
}

class LoadFavoritesEvent extends FavoritesEvent {
  const LoadFavoritesEvent();
}

class ToggleFavoriteEvent extends FavoritesEvent {
  final FavoriteProduct product;
  const ToggleFavoriteEvent(this.product);
}

class ChangeFavoritesTabEvent extends FavoritesEvent {
  final int index;
  const ChangeFavoritesTabEvent(this.index);
}
