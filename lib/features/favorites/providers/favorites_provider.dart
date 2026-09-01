import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/hive_services.dart';
import '../../../core/network/api_client.dart';
import '../data/favorites_repository.dart';
import '../models/favorite_product.dart';

final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  return FavoritesRepository(ApiClient.instance);
});

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

/// M82-M84. Backed by the real API now (was local `flutter_secure_storage`
/// persistence before) — [toggle] is optimistic (updates state immediately)
/// and rolls back if the API call fails.
class FavoritesNotifier extends Notifier<FavoritesState> {
  FavoritesRepository get _repository => ref.read(favoritesRepositoryProvider);

  @override
  FavoritesState build() {
    if (SecureStorage.isAuthenticated) _load();
    return const FavoritesState(isLoading: true);
  }

  Future<void> _load() async {
    final result = await _repository.getFavorites();
    state = state.copyWith(favorites: result.dataOrNull ?? const [], isLoading: false);
  }

  Future<void> refresh() => _load();

  Future<void> toggle(FavoriteProduct product) async {
    final isFavorited = state.favorites.contains(product);
    final previous = state.favorites;

    state = state.copyWith(
      favorites: isFavorited
          ? previous.where((p) => p != product).toList()
          : [...previous, product],
    );

    final result = isFavorited
        ? await _repository.removeFavorite(product.productId)
        : await _repository.addFavorite(product.productId);

    if (!result.isSuccess) {
      state = state.copyWith(favorites: previous);
    }
  }

  void changeTab(int index) {
    state = state.copyWith(selectedTab: index);
  }
}

final favoritesProvider = NotifierProvider<FavoritesNotifier, FavoritesState>(
  FavoritesNotifier.new,
);
