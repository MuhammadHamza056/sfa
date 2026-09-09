import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/providers/realtime_providers.dart';
import '../data/notification_models.dart';
import '../data/notifications_repository.dart';

final notificationsRepositoryProvider = Provider<NotificationsRepository>((ref) {
  return NotificationsRepository(ApiClient.instance);
});

/// `notification:new` off the socket, parsed. Kept here rather than in
/// `core/providers/realtime_providers.dart` so the notification model stays
/// owned by its feature.
final realtimeNotificationProvider = StreamProvider<AppNotification>((ref) {
  return ref
      .watch(socketServiceProvider)
      .notifications
      .map(AppNotification.fromJson);
});

/// M97, plus the live feed: notifications pushed over the socket are
/// prepended to the fetched page, so the list and the unread badge update
/// without a refetch.
///
/// Deliberately not `autoDispose` — the badge is read from the shell on
/// every tab, and dropping the list between visits would drop the live
/// arrivals with it.
class NotificationsNotifier extends AsyncNotifier<List<AppNotification>> {
  @override
  Future<List<AppNotification>> build() async {
    // Established per build: Riverpod tears the subscription down when the
    // provider is invalidated (pull-to-refresh), so it never stacks up.
    ref.listen(realtimeNotificationProvider, (_, next) {
      final notification = next.valueOrNull;
      if (notification != null) prepend(notification);
    });

    final result = await ref.read(notificationsRepositoryProvider).getNotifications();
    return result.when(success: (data) => data, failure: (e) => throw e);
  }

  /// Puts a freshly pushed notification at the top of the list. Ignored
  /// while the first fetch is still in flight (that fetch will contain it
  /// anyway) and when the id is already known, since FCM and the socket can
  /// both deliver the same notification.
  void prepend(AppNotification notification) {
    final current = state.valueOrNull;
    if (current == null) return;
    if (notification.id.isNotEmpty && current.any((n) => n.id == notification.id)) {
      return;
    }
    state = AsyncData([notification, ...current]);
  }

  /// M98. Marks the local copies read on success instead of refetching, so
  /// the badge clears in the same frame as the tap.
  Future<bool> markAllRead() async {
    final result = await ref.read(notificationsRepositoryProvider).markAllRead();
    if (!result.isSuccess) return false;
    final current = state.valueOrNull;
    if (current != null) {
      state = AsyncData([for (final n in current) n.copyWith(isRead: true)]);
    }
    return true;
  }
}

final notificationsListProvider =
    AsyncNotifierProvider<NotificationsNotifier, List<AppNotification>>(
  NotificationsNotifier.new,
);

/// Unread count for the bottom-nav badge.
final unreadNotificationsCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationsListProvider).valueOrNull;
  if (notifications == null) return 0;
  return notifications.where((n) => !n.isRead).length;
});

/// M99
final offerNotificationsProvider = FutureProvider<List<OfferNotification>>((ref) async {
  final result = await ref.read(notificationsRepositoryProvider).getOffers();
  return result.when(success: (data) => data, failure: (e) => throw e);
});
