import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../hive_services.dart';
import '../network/api_client.dart';
import '../../features/notifications/data/notifications_repository.dart';

/// Runs in a separate isolate on Android, so it needs its own Firebase init
/// and must stay a top-level (or static) function.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

/// Wires the app up to FCM: permission request, token registration (M96)
/// and foreground/opened-app message streams.
class PushNotificationsService {
  PushNotificationsService._internal();

  static final PushNotificationsService instance = PushNotificationsService._internal();

  final _messaging = FirebaseMessaging.instance;
  final _repository = NotificationsRepository(ApiClient.instance);
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    await _messaging.requestPermission(alert: true, badge: true, sound: true);
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    _messaging.onTokenRefresh.listen((_) => registerCurrentToken());

    FirebaseMessaging.onMessage.listen((message) {
      debugPrint('FCM foreground message: ${message.messageId} ${message.notification?.title}');
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint('FCM message opened app: ${message.messageId}');
    });

    await registerCurrentToken();
  }

  /// Sends the current device token to the backend (M96). No-op while
  /// signed out, since the endpoint associates the token with a user.
  Future<void> registerCurrentToken() async {
    if (!SecureStorage.isAuthenticated) return;

    final token = await _messaging.getToken();
    if (token == null) return;

    await _repository.registerDeviceToken(
      token: token,
      platform: defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android',
    );
  }
}
