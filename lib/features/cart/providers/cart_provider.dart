import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/hive_services.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_result.dart';
import '../data/cart_models.dart';
import '../data/cart_repository.dart';

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  return CartRepository(ApiClient.instance);
});

/// M27-M36. Cart requires auth, so [build] skips the network call entirely
/// for a signed-out session instead of surfacing a 401 as a screen error.
class CartNotifier extends AsyncNotifier<CartData> {
  CartRepository get _repository => ref.read(cartRepositoryProvider);

  @override
  Future<CartData> build() async {
    if (!SecureStorage.isAuthenticated) return const CartData();
    final result = await _repository.getCart();
    return result.dataOrNull ?? const CartData();
  }

  /// Runs a mutation while keeping the last-known cart visible (as
  /// `state.value`) so the screen can show a spinner over existing content
  /// instead of blanking out; a failure keeps that same previous data.
  Future<void> _mutate(Future<ApiResult<CartData>> Function() call) async {
    state = const AsyncLoading<CartData>().copyWithPrevious(state);
    final result = await call();
    result.when(
      success: (data) => state = AsyncData(data),
      failure: (error) =>
          state = AsyncError<CartData>(error, StackTrace.current).copyWithPrevious(state),
    );
  }

  Future<void> refresh() => _mutate(_repository.getCart);

  /// M28. Returns whether the add actually succeeded — `_mutate` swallows
  /// errors into `state` rather than throwing, so callers that want to show
  /// a success/error message must check this instead of assuming success.
  Future<bool> addItem({
    required String productId,
    int quantity = 1,
    String? selectedSize,
    String? selectedColor,
  }) async {
    await _mutate(() => _repository.addItem(
          productId: productId,
          quantity: quantity,
          selectedSize: selectedSize,
          selectedColor: selectedColor,
        ));
    return !state.hasError;
  }

  /// M29
  Future<void> updateQuantity(String cartItemId, int quantity) {
    return _mutate(() => _repository.updateItem(cartItemId, quantity: quantity));
  }

  /// M30
  Future<void> removeItem(String cartItemId) {
    return _mutate(() => _repository.removeItem(cartItemId));
  }

  /// M31
  Future<void> moveToFavorite(String cartItemId) {
    return _mutate(() => _repository.moveToFavorite(cartItemId));
  }

  /// M32
  Future<void> applyCoupon(String code) {
    return _mutate(() => _repository.applyCoupon(code));
  }

  /// M33
  Future<void> removeCoupon() {
    return _mutate(_repository.removeCoupon);
  }

  /// M34
  Future<void> setGiftWrap({
    required bool giftWrap,
    String? giftMessage,
  }) {
    return _mutate(() => _repository.setGiftWrap(
          giftWrap: giftWrap,
          giftMessage: giftMessage,
        ));
  }

  /// M35
  Future<void> redeemPoints(int points) {
    return _mutate(() => _repository.redeemPoints(points));
  }
}

final cartProvider = AsyncNotifierProvider<CartNotifier, CartData>(
  CartNotifier.new,
);

/// Total item count for the cart badge shown in every app bar.
final cartItemCountProvider = Provider<int>((ref) {
  return ref.watch(cartProvider).valueOrNull?.itemsCount ?? 0;
});
