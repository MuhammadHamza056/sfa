# Google / Apple Sign-In — setup checklist

The Flutter side is complete (`lib/features/auth/data/social_auth_service.dart`,
`auth_provider.dart` → `/auth/oauth/google`, `/auth/oauth/apple`). What is
missing is console configuration. Nothing below requires a code change unless
noted.

## 1. Google — Firebase console

- [x] Google enabled in Authentication → Sign-in method.
- [x] `ios/Runner/GoogleService-Info.plist` has `CLIENT_ID` + `REVERSED_CLIENT_ID`.
- [x] `ios/Runner/Info.plist` URL scheme set to the reversed client ID.
- [x] `lib/firebase_options.dart` carries `iosClientId`.
- [x] `android/app/google-services.json` has the Web client (`client_type: 3`) →
      the Gradle plugin turns it into `default_web_client_id`.
- [ ] **Android SHA-1 still missing.** `google-services.json` has no
      `client_type: 1` entry, which means no Android OAuth client is registered
      for `com.vga.sfa`. Google will reject the sign-in even though the web
      client is present.

To finish: Firebase console → Project settings → Your apps → Android app
(`com.vga.sfa`) → **Add fingerprint** → paste the SHA-1, then re-download
`google-services.json` into `android/app/` and confirm a `client_type: 1` entry
with an `android_info.certificate_hash` now exists.

Debug keystore SHA-1 on this machine:

```
07:C8:40:B3:20:8A:21:CE:3B:7C:90:18:5E:72:42:21:A5:FB:EE:76
```

`android/app/build.gradle.kts` currently signs release with the debug config, so
this one fingerprint covers both build types today. Add the release/upload
keystore SHA-1 **and** the Play App Signing SHA-1 before shipping, or Google
sign-in will work in debug and silently fail in production.

## 2. Apple — Apple Developer portal

- **iOS**: the `com.apple.developer.applesignin` entitlement is already in
  `ios/Runner/Runner.entitlements`. You still need to enable the **Sign in with
  Apple** capability on the App ID `com.vga.sfa` in the Apple Developer portal
  and regenerate the provisioning profiles. Requires a paid Apple Developer
  account; it does not work on the Simulator without a signed-in Apple ID.
- **Android** (only if you want the Apple button there too): create a
  **Services ID** + **Sign in with Apple key**, host a redirect endpoint on the
  backend, then build with:
  ```
  flutter run \
    --dart-define=APPLE_SERVICE_ID=com.vga.sfa.web \
    --dart-define=APPLE_REDIRECT_URI=https://<api-host>/api/v1/auth/oauth/apple/callback
  ```
  While these are unset the Apple button is hidden on Android and Google goes
  full width — deliberate, see `SocialAuthConfig.socialAppleEnabled`.
  The redirect endpoint must 302 back to
  `intent://callback?<apple form body>#Intent;package=com.vga.sfa;scheme=signinwithapple;end`.

## 3. Backend

- `POST /auth/oauth/google` and `POST /auth/oauth/apple` receive
  `{ providerType, idToken, email?, name? }` and must return the same session
  shape as email login (`user` + `tokens.accessToken` + `tokens.refreshToken`).
- **Google audience**: the ID token's `aud` differs by platform — the **web
  client ID** on Android, the **iOS client ID** on iOS. Verification must accept
  both, or Google login works on one platform and fails on the other.
- **Apple audience**: `aud` is the **bundle ID** (`com.vga.sfa`) for the native
  iOS flow and the **Services ID** for the Android web flow. Same rule: accept
  both.
- Apple only sends `email`/`name` on the *first* authorization. The app caches
  and resends them, but the backend must key the account on the token's `sub`
  claim, not on email.

## 4. Values to hand back for CI builds (optional)

```
--dart-define=GOOGLE_SERVER_CLIENT_ID=<web client ID, client_type 3>
--dart-define=GOOGLE_IOS_CLIENT_ID=<CLIENT_ID from GoogleService-Info.plist>
--dart-define=APPLE_SERVICE_ID=<Services ID>
--dart-define=APPLE_REDIRECT_URI=<backend callback URL>
```
