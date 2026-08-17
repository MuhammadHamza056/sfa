import 'package:flutter/foundation.dart';
import '../models/favorite_product.dart';

@immutable
class FavoritesState {
  final List<FavoriteProduct> favorites;
  final bool isLoading;
  final int selectedTab;

  const FavoritesState({
    this.favorites = const [],
    this.isLoading = false,
    this.selectedTab = 0,
  });

  FavoritesState copyWith({
    List<FavoriteProduct>? favorites,
    bool? isLoading,
    int? selectedTab,
  }) {
    return FavoritesState(
      favorites: favorites ?? this.favorites,
      isLoading: isLoading ?? this.isLoading,
      selectedTab: selectedTab ?? this.selectedTab,
    );
  }
}
