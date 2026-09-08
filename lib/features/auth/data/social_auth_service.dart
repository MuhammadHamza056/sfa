import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../core/hive_services.dart';
import '../../../core/network/app_config.dart';

/// What the provider SDKs hand back once the user finishes the native
/// sheet — exactly the three fields M06/M07 post to the backend.
class SocialCredential {
  const SocialCredential({required this.idToken, this.email, this.name});

  /// The JWT the backend verifies against the provider. Always present:
  /// a flow that can't produce one throws instead.
  final String idToken;

  /// Both are best-effort. Google always fills them in; Apple only does on
  /// the first authorization, and even then the user can hide their email.
  final String? email;
  final String? name;
}

/// The user backed out of the provider sheet. Not an error — the UI just
/// returns to where it was without a toast.
class SocialAuthCancelled implements Exception {
  const SocialAuthCancelled();
}

/// Anything that actually went wrong, already phrased for the user.
class SocialAuthFailure implements Exception {
  const SocialAuthFailure(this.message);

  final String message;

  @override
  String toString() => 'SocialAuthFailure: $message';
}

/// Drives the Google and Apple native sign-in sheets.
///
/// Deliberately knows nothing about our API: it returns the provider's ID
/// token and lets [AuthNotifier] exchange it for a session, so the
/// backend stays the only thing that mints our own tokens.
class SocialAuthService {
  SocialAuthService._();

  static bool _googleInitialized = false;

  /// The iOS/macOS OAuth client, from the `--dart-define` if CI supplied one
  /// and otherwise from `GoogleService-Info.plist` by way of the FlutterFire
  /// options — `iosClientId` is only written when the Firebase project
  /// actually has an iOS OAuth client, which makes it a usable "is Google
  /// sign-in set up for this build?" probe. Null on every other platform,
  /// where the client comes from `google-services.json` instead.
  static String? get _darwinClientId {
    if (SocialAuthConfig.googleIosClientId.isNotEmpty) {
      return SocialAuthConfig.googleIosClientId;
    }
    if (Platform.isIOS || Platform.isMacOS) {
      return Firebase.apps.isEmpty ? null : Firebase.app().options.iosClientId;
    }
    return null;
  }

  /// [GoogleSignIn.initialize] has to run once before anything else, and
  /// running it twice is wasteful, so the first caller wins.
  static Future<GoogleSignIn> _google() async {
    final signIn = GoogleSignIn.instance;
    if (_googleInitialized) return signIn;

    final clientId = _darwinClientId;
    if ((Platform.isIOS || Platform.isMacOS) &&
        (clientId == null || clientId.isEmpty)) {
      // Without a client ID the underlying GIDSignIn raises an Objective-C
      // exception that Dart can't catch, so the app would die on the tap.
      // Refuse here instead and let the caller show the error.
      throw const SocialAuthFailure(
        'Google sign-in is misconfigured: no iOS client ID. '
        'Check CLIENT_ID in GoogleService-Info.plist.',
      );
    }

    try {
      await signIn.initialize(
        // Empty means "not configured in Dart" — the plugin then falls
        // back to GoogleService-Info.plist / google-services.json.
        clientId: clientId,
        serverClientId: SocialAuthConfig.googleServerClientId.isEmpty
            ? null
            : SocialAuthConfig.googleServerClientId,
      );
    } on GoogleSignInException catch (e) {
      throw SocialAuthFailure(
        'Google sign-in is misconfigured: ${e.description ?? e.code.name}',
      );
    }
    _googleInitialized = true;
    return signIn;
  }

  /// M06 — opens the Google account picker and returns its ID token.
  static Future<SocialCredential> signInWithGoogle() async {
    final signIn = await _google();

    if (!signIn.supportsAuthenticate()) {
      throw const SocialAuthFailure(
        'Google sign-in is not available on this device',
      );
    }

    final GoogleSignInAccount account;
    try {
      account = await signIn.authenticate();
    } on GoogleSignInException catch (e) {
      switch (e.code) {
        // Android's Credential Manager also reports a misconfigured client
        // as a cancel, so a "cancel" here isn't always the user's doing —
        // see the google_sign_in_android troubleshooting notes.
        case GoogleSignInExceptionCode.canceled:
        case GoogleSignInExceptionCode.interrupted:
          throw const SocialAuthCancelled();
        case GoogleSignInExceptionCode.clientConfigurationError:
          throw SocialAuthFailure(
            'Google sign-in is misconfigured: ${e.description ?? e.code.name}',
          );
        default:
          throw SocialAuthFailure(
            e.description ?? 'Google sign-in failed. Please try again.',
          );
      }
    }

    final idToken = account.authentication.idToken;
    if (idToken == null) {
      // Practically always a missing/mismatched web client ID: without one
      // Google has no audience to mint an ID token for.
      throw const SocialAuthFailure(
        'Google did not return an ID token. Check the server client ID.',
      );
    }

    return SocialCredential(
      idToken: idToken,
      email: account.email,
      name: account.displayName,
    );
  }

  /// M07 — the native Apple sheet on iOS/macOS, the web flow elsewhere.
  static Future<SocialCredential> signInWithApple() async {
    if (!SocialAuthConfig.socialAppleEnabled) {
      throw const SocialAuthFailure(
        'Sign in with Apple is not available on this device',
      );
    }

    final AuthorizationCredentialAppleID credential;
    try {
      credential = await SignInWithApple.getAppleIDCredential(
        scopes: const [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        // iOS/macOS use the native sheet and must not get these; every
        // other platform is driven through Apple's web endpoint.
        webAuthenticationOptions: Platform.isIOS || Platform.isMacOS
            ? null
            : WebAuthenticationOptions(
                clientId: SocialAuthConfig.appleServiceId,
                redirectUri: Uri.parse(SocialAuthConfig.appleRedirectUri),
              ),
      );
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        throw const SocialAuthCancelled();
      }
      throw SocialAuthFailure(
        e.message.isEmpty ? 'Apple sign-in failed. Please try again.' : e.message,
      );
    } on SignInWithAppleNotSupportedException {
      throw const SocialAuthFailure(
        'Sign in with Apple is not available on this device',
      );
    } on SignInWithAppleException {
      throw const SocialAuthFailure('Apple sign-in failed. Please try again.');
    }

    final idToken = credential.identityToken;
    if (idToken == null) {
      throw const SocialAuthFailure('Apple did not return an identity token.');
    }

    // First authorization only — cache it so later sign-ins, which come
    // back nameless, can still send the backend something to display.
    final name = [
      credential.givenName,
      credential.familyName,
    ].whereType<String>().where((part) => part.isNotEmpty).join(' ');

    await SecureStorage.putAppleIdentity(
      name: name,
      email: credential.email,
    );

    return SocialCredential(
      idToken: idToken,
      email: credential.email ?? SecureStorage.getAppleEmail(),
      name: name.isNotEmpty ? name : SecureStorage.getAppleName(),
    );
  }

  /// Clears the Google session so the next sign-in shows the account
  /// picker again instead of silently reusing the last account. Apple has
  /// no equivalent — its session lives in the OS.
  static Future<void> signOut() async {
    if (!_googleInitialized) return;
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {
      // Logging out locally must succeed even if the SDK complains.
    }
  }
}
