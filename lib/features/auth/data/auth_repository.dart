import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_result.dart';
import 'auth_models.dart';

/// M01-M11 from the guide. Every method returns an [ApiResult] — the
/// provider decides how to react instead of catching exceptions.
///
/// The guide was revised after the first pass at this repository — several
/// paths and body field names changed. This reflects the current guide;
/// see individual method comments for anything still inferred rather than
/// directly documented.
class AuthRepository {
  AuthRepository(this._client);

  final ApiClient _client;

  /// M01: Request Phone/Email SMS OTP
  Future<ApiResult<OtpRequestResult>> sendOtp({
    required String countryCode,
    required String phoneNumber,
    String type = 'user',
  }) {
    return _client.post<OtpRequestResult>(
      ApiEndpoints.otpSend,
      data: {
        'countryCode': countryCode,
        'phoneNumber': phoneNumber,
        'type': type,
      },
      fromJson: (data) =>
          OtpRequestResult.fromJson(data as Map<String, dynamic>),
    );
  }

  /// M02: Verify Phone/Email OTP & get auth tokens. `type` is the OTP
  /// purpose — the backend only accepts `SIGNUP_VERIFY` or
  /// `FORGOT_PASSWORD`, so the phone login flow reuses `SIGNUP_VERIFY` too
  /// since there's no dedicated login type. `targetType` is the guide's
  /// separate, unchanged field (audience — "user").
  Future<ApiResult<AuthSession>> verifyOtp({
    required String countryCode,
    required String phoneNumber,
    required String otp,
    String type = 'SIGNUP_VERIFY',
    String targetType = 'user',
  }) {
    return _client.post<AuthSession>(
      ApiEndpoints.otpVerify,
      data: {
        'countryCode': countryCode,
        'phoneNumber': phoneNumber,
        'otp': otp,
        'type': type,
        'targetType': targetType,
      },
      fromJson: (data) => AuthSession.fromJson(data as Map<String, dynamic>),
    );
  }

  /// M03: Resend verification or reset OTP (was a re-send of M01 in the
  /// original guide — now its own endpoint).
  Future<ApiResult<void>> resendOtp({
    required String countryCode,
    required String phoneNumber,
    String type = 'SIGNUP_VERIFY',
    String targetType = 'user',
  }) {
    return _client.post<void>(
      ApiEndpoints.otpResend,
      data: {
        'countryCode': countryCode,
        'phoneNumber': phoneNumber,
        'type': type,
        'targetType': targetType,
      },
      fromJson: (_) {},
    );
  }

  /// M04: Login with email+password OR phone+password.
  Future<ApiResult<AuthSession>> login({
    String? email,
    String? countryCode,
    String? phoneNumber,
    required String password,
  }) {
    return _client.post<AuthSession>(
      ApiEndpoints.login,
      data: {
        if (email != null) 'email': email,
        if (countryCode != null) 'countryCode': countryCode,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
        'password': password,
      },
      fromJson: (data) => AuthSession.fromJson(data as Map<String, dynamic>),
    );
  }

  /// M05: Register Customer — sends an OTP server-side; does not return a
  /// session. See [RegisterResult].
  Future<ApiResult<RegisterResult>> register({
    required String name,
    required String email,
    required String password,
    required String countryCode,
    required String phoneNumber,
    String? referralCode,
  }) {
    return _client.post<RegisterResult>(
      ApiEndpoints.register,
      data: {
        'name': name,
        'email': email,
        'password': password,
        'role': 'user',
        'countryCode': countryCode,
        'phoneNumber': phoneNumber,
        if (referralCode != null && referralCode.isNotEmpty)
          'referralCode': referralCode,
      },
      fromJson: (data) => RegisterResult.fromJson(data as Map<String, dynamic>),
    );
  }

  /// M06: Google OAuth Sign-In
  Future<ApiResult<AuthSession>> googleSignIn({
    required String idToken,
    required String email,
    required String name,
  }) {
    return _client.post<AuthSession>(
      ApiEndpoints.googleSignIn,
      data: {
        'email': email,
        'name': name,
        'providerType': 'google',
        'idToken': idToken,
      },
      fromJson: (data) => AuthSession.fromJson(data as Map<String, dynamic>),
    );
  }

  /// M07: Apple OAuth Sign-In
  Future<ApiResult<AuthSession>> appleSignIn({
    required String idToken,
    required String email,
    required String name,
  }) {
    return _client.post<AuthSession>(
      ApiEndpoints.appleSignIn,
      data: {
        'email': email,
        'name': name,
        'providerType': 'apple',
        'idToken': idToken,
      },
      fromJson: (data) => AuthSession.fromJson(data as Map<String, dynamic>),
    );
  }

  /// M08: Revoke active session tokens
  Future<ApiResult<void>> logout() {
    return _client.post<void>(ApiEndpoints.logout, fromJson: (_) {});
  }

  /// M10: Request password reset OTP
  Future<ApiResult<OtpRequestResult>> forgotPasswordRequest({
    required String countryCode,
    required String phoneNumber,
    String type = 'user',
  }) {
    return _client.post<OtpRequestResult>(
      ApiEndpoints.forgotPasswordRequest,
      data: {'countryCode': countryCode, 'phoneNumber': phoneNumber, 'type': type},
      fromJson: (data) =>
          OtpRequestResult.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Not a separate numbered endpoint in the current guide (the old M08
  /// "verify reset OTP" was dropped from the master index) — inferred as a
  /// reuse of M02's `/auth/otp/verify` with `type: FORGOT_PASSWORD` (the
  /// server's confirmed enum, per its `otp/verify` validation error),
  /// expecting a `resetToken` back instead of a session. Still unwired to
  /// any screen — verify the `resetToken` field name against the real
  /// backend before relying on this.
  Future<ApiResult<String>> verifyPasswordResetOtp({
    required String countryCode,
    required String phoneNumber,
    required String otp,
  }) {
    return _client.post<String>(
      ApiEndpoints.otpVerify,
      data: {
        'countryCode': countryCode,
        'phoneNumber': phoneNumber,
        'otp': otp,
        'type': 'FORGOT_PASSWORD',
        'targetType': 'user',
      },
      fromJson: (data) =>
          (data as Map<String, dynamic>)['resetToken'] as String,
    );
  }

  /// M11: Set new password with verified reset token
  Future<ApiResult<void>> forgotPasswordReset({
    required String resetToken,
    required String newPassword,
  }) {
    return _client.post<void>(
      ApiEndpoints.forgotPasswordReset,
      data: {'resetToken': resetToken, 'newPassword': newPassword},
      fromJson: (_) {},
    );
  }
}
