import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'favorites_event.dart';
import 'favorites_state.dart';
import '../models/favorite_product.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  static const String _favoritesKey = 'favorite_products';

  FavoritesBloc() : super(const FavoritesState()) {
    on<LoadFavoritesEvent>(_onLoadFavorites);
    on<ToggleFavoriteEvent>(_onToggleFavorite);
    on<ChangeFavoritesTabEvent>((event, emit) {
      emit(state.copyWith(selectedTab: event.index));
    });
  }

  Future<void> _onLoadFavorites(
    LoadFavoritesEvent event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final jsonString = await _storage.read(key: _favoritesKey);
      if (jsonString != null) {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        final favorites = jsonList
            .map((item) => FavoriteProduct.fromJson(item as Map<String, dynamic>))
            .toList();
        emit(state.copyWith(favorites: favorites, isLoading: false));
      } else {
        emit(state.copyWith(favorites: [], isLoading: false));
      }
    } catch (_) {
      emit(state.copyWith(favorites: [], isLoading: false));
    }
  }

  Future<void> _onToggleFavorite(
    ToggleFavoriteEvent event,
    Emitter<FavoritesState> emit,
  ) async {
    final updatedFavorites = List<FavoriteProduct>.from(state.favorites);
    if (updatedFavorites.contains(event.product)) {
      updatedFavorites.remove(event.product);
    } else {
      updatedFavorites.add(event.product);
    }
    
    emit(state.copyWith(favorites: updatedFavorites));

    try {
      final jsonString = jsonEncode(
        updatedFavorites.map((item) => item.toJson()).toList(),
      );
      await _storage.write(key: _favoritesKey, value: jsonString);
    } catch (_) {
      // Handle or log error
    }
  }
}
