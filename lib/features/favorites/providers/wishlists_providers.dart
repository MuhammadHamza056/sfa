import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../data/wishlist_models.dart';
import '../data/wishlists_repository.dart';

final wishlistsRepositoryProvider = Provider<WishlistsRepository>((ref) {
  return WishlistsRepository(ApiClient.instance);
});

/// M85
final wishlistsListProvider = FutureProvider<List<WishlistSummary>>((ref) async {
  final result = await ref.read(wishlistsRepositoryProvider).getWishlists();
  return result.when(success: (data) => data, failure: (e) => throw e);
});

/// M87 — keyed by wishlist id.
final wishlistDetailProvider = FutureProvider.family<WishlistDetail, String>((ref, id) async {
  final result = await ref.read(wishlistsRepositoryProvider).getWishlist(id);
  return result.when(success: (data) => data, failure: (e) => throw e);
});

/// M91 — keyed by share token, public.
final sharedWishlistProvider = FutureProvider.family<WishlistDetail, String>((ref, token) async {
  final result = await ref.read(wishlistsRepositoryProvider).getSharedWishlist(token);
  return result.when(success: (data) => data, failure: (e) => throw e);
});
