import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/hive_services.dart';
import 'core/localization/app_localizations.dart';
import 'core/network/socket_service.dart';
import 'core/notifications/push_notifications_service.dart';
import 'core/notifications/realtime_listener.dart';
import 'core/routes.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_notifier.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await SecureStorage.init();
  await PushNotificationsService.instance.initialize();
  // Re-opens the real-time connection for a session that survived the last
  // run; a no-op while signed out. Sign-in/sign-out are handled by
  // `AuthNotifier`.
  SocketService.instance.connect();
  themeNotifier.loadFromStorage();
  localeNotifier.loadFromStorage();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: localeNotifier,
      builder: (context, locale, child) {
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: themeNotifier,
          builder: (context, themeMode, child) {
            return MaterialApp.router(
              title: 'SFA Mobile App',
              debugShowCheckedModeBanner: false,
              locale: locale,
              supportedLocales: const [Locale('ar'), Locale('en')],
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: themeMode,
              routerConfig: router,
              // Sits under the router's Navigator (and under
              // `ScaffoldMessenger`) so socket events can refresh providers
              // and raise a snackbar from any screen.
              builder: (context, child) =>
                  RealtimeListener(child: child ?? const SizedBox.shrink()),
            );
          },
        );
      },
    );
  }
}

// customer@safa.sa

// +966500000001
// Test@1234
