import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../data/order_models.dart';
import '../data/orders_repository.dart';

final ordersRepositoryProvider = Provider<OrdersRepository>((ref) {
  return OrdersRepository(ApiClient.instance);
});

/// M50 — the full first page of orders; [PreviousOrdersScreen]'s two tabs
/// split this client-side via [Order.isActive] rather than firing two
/// separate status-filtered requests.
///
/// `autoDispose` — without it this stays cached for the app's lifetime, so
/// leaving the orders list and coming back (e.g. after cancelling an order)
/// would keep serving the first fetch instead of hitting the API again.
final ordersDataProvider = FutureProvider.autoDispose<List<Order>>((ref) async {
  final result = await ref.read(ordersRepositoryProvider).getOrders(limit: 50);
  return result.when(success: (data) => data.items, failure: (e) => throw e);
});

/// M51 — keyed by order id. `autoDispose` for the same reason as
/// [ordersDataProvider] — otherwise re-opening a previously visited order's
/// tracking page never refetches.
final orderDetailProvider = FutureProvider.autoDispose.family<OrderDetail, String>((ref, id) async {
  final result = await ref.read(ordersRepositoryProvider).getOrderDetail(id);
  return result.when(success: (data) => data, failure: (e) => throw e);
});

/// M52 — keyed by order id. Named `orderTrackingDataProvider` (not
/// `orderTrackingProvider`) since that name is already the UI-state
/// notifier in `features/orders/providers/order_tracking_provider.dart`.
/// `autoDispose` for the same reason as [orderDetailProvider].
final orderTrackingDataProvider =
    FutureProvider.autoDispose.family<OrderTracking, String>((ref, id) async {
  final result = await ref.read(ordersRepositoryProvider).getOrderTracking(id);
  return result.when(success: (data) => data, failure: (e) => throw e);
});

/// M60
final orderStatisticsProvider = FutureProvider<OrderStatistics>((ref) async {
  final result = await ref.read(ordersRepositoryProvider).getStatistics();
  return result.when(success: (data) => data, failure: (e) => throw e);
});

/// M55 — keyed by order id. `autoDispose` for the same reason as
/// [ordersDataProvider] — otherwise leaving the refund-request page and
/// coming back keeps serving the first fetch instead of hitting the API
/// again.
final returnableItemsProvider =
    FutureProvider.autoDispose.family<List<ReturnableItem>, String>((ref, id) async {
  final result = await ref.read(ordersRepositoryProvider).getReturnableItems(id);
  return result.when(success: (data) => data, failure: (e) => throw e);
});
