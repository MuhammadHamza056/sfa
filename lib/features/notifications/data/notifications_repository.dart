import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_result.dart';
import 'notification_models.dart';

/// M96-M99 from the guide.
class NotificationsRepository {
  NotificationsRepository(this._client);

  final ApiClient _client;

  /// M97: Customer notifications list
  Future<ApiResult<List<AppNotification>>> getNotifications() {
    return _client.get<List<AppNotification>>(
      ApiEndpoints.notifications,
      fromJson: (data) {
        final raw = data is Map<String, dynamic> && data['items'] is List
            ? data['items'] as List
            : (data is List ? data : const []);
        return raw.map((v) => AppNotification.fromJson(v as Map<String, dynamic>)).toList();
      },
    );
  }

  /// M98: Mark all notifications as read
  Future<ApiResult<void>> markAllRead() {
    return _client.put<void>(ApiEndpoints.notificationsRead, fromJson: (_) {});
  }

  /// M99: Promotional offers notifications
  Future<ApiResult<List<OfferNotification>>> getOffers() {
    return _client.get<List<OfferNotification>>(
      ApiEndpoints.notificationOffers,
      fromJson: (data) {
        final raw = data is Map<String, dynamic> && data['items'] is List
            ? data['items'] as List
            : (data is List ? data : const []);
        return raw.map((v) => OfferNotification.fromJson(v as Map<String, dynamic>)).toList();
      },
    );
  }

  /// M96: Register FCM push device token. No push package (e.g.
  /// `firebase_messaging`) is wired into the app yet, so nothing calls this
  /// automatically — it's here for whenever push notifications are added.
  Future<ApiResult<void>> registerDeviceToken({
    required String token,
    required String platform,
  }) {
    return _client.post<void>(
      ApiEndpoints.notificationDeviceToken,
      data: {'token': token, 'platform': platform},
      fromJson: (_) {},
    );
  }
}
