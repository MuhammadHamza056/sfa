import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../data/notification_models.dart';
import '../data/notifications_repository.dart';

final notificationsRepositoryProvider = Provider<NotificationsRepository>((ref) {
  return NotificationsRepository(ApiClient.instance);
});

/// M97
final notificationsListProvider = FutureProvider<List<AppNotification>>((ref) async {
  final result = await ref.read(notificationsRepositoryProvider).getNotifications();
  return result.when(success: (data) => data, failure: (e) => throw e);
});

/// M99
final offerNotificationsProvider = FutureProvider<List<OfferNotification>>((ref) async {
  final result = await ref.read(notificationsRepositoryProvider).getOffers();
  return result.when(success: (data) => data, failure: (e) => throw e);
});
