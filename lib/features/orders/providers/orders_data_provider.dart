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
final ordersDataProvider = FutureProvider<List<Order>>((ref) async {
  final result = await ref.read(ordersRepositoryProvider).getOrders(limit: 50);
  return result.when(success: (data) => data.items, failure: (e) => throw e);
});

/// M51 — keyed by order id.
final orderDetailProvider = FutureProvider.family<OrderDetail, String>((ref, id) async {
  final result = await ref.read(ordersRepositoryProvider).getOrderDetail(id);
  return result.when(success: (data) => data, failure: (e) => throw e);
});

/// M52 — keyed by order id. Named `orderTrackingDataProvider` (not
/// `orderTrackingProvider`) since that name is already the UI-state
/// notifier in `features/orders/providers/order_tracking_provider.dart`.
final orderTrackingDataProvider = FutureProvider.family<OrderTracking, String>((ref, id) async {
  final result = await ref.read(ordersRepositoryProvider).getOrderTracking(id);
  return result.when(success: (data) => data, failure: (e) => throw e);
});

/// M60
final orderStatisticsProvider = FutureProvider<OrderStatistics>((ref) async {
  final result = await ref.read(ordersRepositoryProvider).getStatistics();
  return result.when(success: (data) => data, failure: (e) => throw e);
});

/// M55 — keyed by order id.
final returnableItemsProvider =
    FutureProvider.family<List<ReturnableItem>, String>((ref, id) async {
  final result = await ref.read(ordersRepositoryProvider).getReturnableItems(id);
  return result.when(success: (data) => data, failure: (e) => throw e);
});
