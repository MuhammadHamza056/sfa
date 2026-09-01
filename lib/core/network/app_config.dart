import 'dart:io';

/// Where the app points its network calls.
///
/// Flip [environment] to switch every request between the staging API and
/// a local backend without touching call sites. Local URLs differ by
/// platform because the iOS simulator can reach `localhost` directly while
/// the Android emulator must go through the `10.0.2.2` host alias.
enum ApiEnvironment { staging, local }

class AppConfig {
  AppConfig._();

  static const ApiEnvironment environment = ApiEnvironment.staging;

  static const String _stagingBaseUrl =
      'https://2cc6-39-37-128-76.ngrok-free.app/api/v1';
  static const String _localIos = 'http://localhost:3000/api/v1';
  static const String _localAndroid = 'http://10.0.2.2:3000/api/v1';

  static String get baseUrl {
    switch (environment) {
      case ApiEnvironment.staging:
        return _stagingBaseUrl;
      case ApiEnvironment.local:
        return Platform.isAndroid ? _localAndroid : _localIos;
    }
  }
}
