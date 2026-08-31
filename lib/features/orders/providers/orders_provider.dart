import 'package:flutter_riverpod/flutter_riverpod.dart';

class OrdersState {
  final bool isProductsExpanded;
  final Map<String, bool> selectedProducts; // Product ID/Name to isSelected
  final String? selectedReason;

  const OrdersState({
    this.isProductsExpanded = true,
    this.selectedProducts = const {},
    this.selectedReason,
  });

  OrdersState copyWith({
    bool? isProductsExpanded,
    Map<String, bool>? selectedProducts,
    String? selectedReason,
  }) {
    return OrdersState(
      isProductsExpanded: isProductsExpanded ?? this.isProductsExpanded,
      selectedProducts: selectedProducts ?? this.selectedProducts,
      selectedReason: selectedReason ?? this.selectedReason,
    );
  }
}

/// Replaces the old per-route `OrdersBloc` used by the refund screens
/// (`/refund-request/:id` and `/refund-status/:id`). Each route wraps
/// itself in its own `ProviderScope(overrides: [ordersProvider])` — see
/// `routes.dart` — so the two screens keep the same isolated, fresh-per-push
/// state the bloc used to get from its own `BlocProvider(create: ...)`.
class OrdersNotifier extends Notifier<OrdersState> {
  @override
  OrdersState build() => const OrdersState();

  void toggleProductsExpanded() {
    state = state.copyWith(isProductsExpanded: !state.isProductsExpanded);
  }

  void toggleProductSelection(String productId, bool isSelected) {
    final updated = Map<String, bool>.from(state.selectedProducts);
    updated[productId] = isSelected;
    state = state.copyWith(selectedProducts: updated);
  }

  void changeRefundReason(String? reason) {
    state = state.copyWith(selectedReason: reason);
  }
}

final ordersProvider = NotifierProvider<OrdersNotifier, OrdersState>(
  OrdersNotifier.new,
);
