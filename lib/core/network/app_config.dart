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
      // 'https://0b8b-103-177-241-226.ngrok-free.app/api/v1';
      'http://3.6.193.117/api/v1';
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

  /// Origin the Socket.IO gateway listens on — the same host as [baseUrl]
  /// minus the `/api/v1` prefix, since the gateway is mounted at the root
  /// (`/socket.io`), not under the REST namespace.
  static String get socketUrl {
    final url = baseUrl;
    return url.endsWith(_apiPrefix)
        ? url.substring(0, url.length - _apiPrefix.length)
        : url;
  }

  static const String _apiPrefix = '/api/v1';
}

/// Client identifiers for the Google / Apple sign-in flows.
///
/// These live outside [AppConfig] because they aren't environment
/// dependent — the same OAuth clients back staging and production.
///
/// Every value can be overridden at build time with `--dart-define`, so CI
/// can inject them without the IDs landing in the repo:
///
/// ```
/// flutter run --dart-define=GOOGLE_SERVER_CLIENT_ID=…
/// ```
class SocialAuthConfig {
  SocialAuthConfig._();

  /// The *web* OAuth client ID (`client_type: 3`). This is the audience the
  /// backend validates the Google ID token against, so it must be set even
  /// though the user signs in from a mobile client.
  ///
  /// On Android this may stay empty: the Gradle plugin picks the same value
  /// out of `google-services.json` automatically, as long as that file has a
  /// web OAuth client entry.
  static const String googleServerClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
  );

  /// The iOS OAuth client ID — `CLIENT_ID` in `GoogleService-Info.plist`.
  /// Only consulted on iOS/macOS; Android ignores it.
  static const String googleIosClientId = String.fromEnvironment(
    'GOOGLE_IOS_CLIENT_ID',
  );

  /// Apple *Services ID* (not the bundle ID) plus the backend URL Apple
  /// redirects to. Both are only needed for the web-based flow Android has
  /// to use — on iOS the native sheet needs neither.
  ///
  /// While these are empty the Apple button simply doesn't render on
  /// Android; see [socialAppleEnabled].
  static const String appleServiceId = String.fromEnvironment(
    'APPLE_SERVICE_ID',
  );

  static const String appleRedirectUri = String.fromEnvironment(
    'APPLE_REDIRECT_URI',
  );

  /// Whether Sign in with Apple can run on the current platform. iOS and
  /// macOS have it natively; anywhere else it needs the Services ID pair
  /// above to fall back to the web flow.
  static bool get socialAppleEnabled {
    if (Platform.isIOS || Platform.isMacOS) return true;
    return appleServiceId.isNotEmpty && appleRedirectUri.isNotEmpty;
  }
}
