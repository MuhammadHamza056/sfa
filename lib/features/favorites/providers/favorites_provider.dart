import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/favorite_product.dart';

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

/// Replaces the old `FavoritesBloc`. Persists to secure storage the same
/// way; the only behavioral difference is that loading now happens lazily
/// on first read instead of being kicked off explicitly at app start.
class FavoritesNotifier extends Notifier<FavoritesState> {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  static const String _favoritesKey = 'favorite_products';

  @override
  FavoritesState build() {
    _load();
    return const FavoritesState(isLoading: true);
  }

  Future<void> _load() async {
    try {
      final jsonString = await _storage.read(key: _favoritesKey);
      if (jsonString != null) {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        final favorites = jsonList
            .map((item) => FavoriteProduct.fromJson(item as Map<String, dynamic>))
            .toList();
        state = state.copyWith(favorites: favorites, isLoading: false);
      } else {
        state = state.copyWith(favorites: [], isLoading: false);
      }
    } catch (_) {
      state = state.copyWith(favorites: [], isLoading: false);
    }
  }

  Future<void> toggle(FavoriteProduct product) async {
    final updatedFavorites = List<FavoriteProduct>.from(state.favorites);
    if (updatedFavorites.contains(product)) {
      updatedFavorites.remove(product);
    } else {
      updatedFavorites.add(product);
    }

    state = state.copyWith(favorites: updatedFavorites);

    try {
      final jsonString = jsonEncode(
        updatedFavorites.map((item) => item.toJson()).toList(),
      );
      await _storage.write(key: _favoritesKey, value: jsonString);
    } catch (_) {
      // Handle or log error
    }
  }

  void changeTab(int index) {
    state = state.copyWith(selectedTab: index);
  }
}

final favoritesProvider = NotifierProvider<FavoritesNotifier, FavoritesState>(
  FavoritesNotifier.new,
);
