import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/realtime_events.dart';
import '../network/socket_service.dart';

/// Riverpod face of [SocketService]. The service itself is a session-scoped
/// singleton (connected on sign-in, dropped on sign-out — see
/// `AuthNotifier`), so these providers only expose its streams; none of
/// them owns the connection.
final socketServiceProvider = Provider<SocketService>((ref) {
  return SocketService.instance;
});

/// Live connection state, for a "reconnecting…" affordance.
final socketConnectedProvider = StreamProvider<bool>((ref) {
  return ref.watch(socketServiceProvider).connectionState;
});

/// `order:status_updated`. Watched app-wide by `RealtimeListener`, which
/// refreshes the affected order providers — screens don't listen to this
/// themselves, they just re-render off the refreshed data.
final orderStatusUpdatesProvider = StreamProvider<RealtimeOrderUpdate>((ref) {
  return ref.watch(socketServiceProvider).orderUpdates;
});

/// Courier GPS pings for one delivery. Watching it joins the delivery's
/// tracking room and leaving the screen (autoDispose) leaves it again, so
/// the app never keeps a GPS feed open behind a closed map.
///
/// Pings that don't name a delivery are passed through: the gateway omits
/// `deliveryId` on some builds, and a socket only receives pings for rooms
/// it actually joined.
final driverLocationProvider = StreamProvider.autoDispose
    .family<DriverLocation, String>((ref, deliveryId) {
  final service = ref.watch(socketServiceProvider);
  service.subscribeToTracking(deliveryId);
  ref.onDispose(() => service.unsubscribeFromTracking(deliveryId));
  return service.driverLocations.where(
    (location) => location.deliveryId == null || location.deliveryId == deliveryId,
  );
});
