class AuthUserPhone {
  final String countryCode;
  final String number;
  final String fullNumber;

  const AuthUserPhone({
    required this.countryCode,
    required this.number,
    required this.fullNumber,
  });

  factory AuthUserPhone.fromJson(Map<String, dynamic> json) {
    return AuthUserPhone(
      countryCode: json['countryCode'] as String? ?? '',
      number: json['number'] as String? ?? '',
      fullNumber: json['fullNumber'] as String? ?? '',
    );
  }
}

class AuthUser {
  final String id;
  final String name;
  final String? email;
  final AuthUserPhone? phone;
  final String role;

  const AuthUser({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    required this.role,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: (json['id'] ?? json['_id'])?.toString() ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String?,
      phone: json['phone'] is Map<String, dynamic>
          ? AuthUserPhone.fromJson(json['phone'] as Map<String, dynamic>)
          : null,
      role: json['role'] as String? ?? 'user',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'role': role,
  };
}

class AuthTokens {
  final String accessToken;
  final String refreshToken;
  final int expiresIn;

  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
  });

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    return AuthTokens(
      accessToken: json['accessToken'] as String? ?? '',
      refreshToken: json['refreshToken'] as String? ?? '',
      expiresIn: (json['expiresIn'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Result of M02 (OTP verify), M03 (register) and M04 (login) — every
/// endpoint in the guide that hands back an authenticated session.
///
/// The guide's own example nests `user`/`tokens`, but the live backend
/// actually returns a flat body (`accessToken`/`refreshToken`/`expiresIn`
/// at the top level, the user under `profile` instead of `user`) — this
/// parses either shape so it keeps working if a different endpoint follows
/// the documented nesting instead.
class AuthSession {
  final AuthUser user;
  final AuthTokens tokens;

  const AuthSession({required this.user, required this.tokens});

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    final userJson =
        (json['profile'] ?? json['user']) as Map<String, dynamic>? ?? const {};
    final tokensJson = json['tokens'] as Map<String, dynamic>? ?? json;
    return AuthSession(
      user: AuthUser.fromJson(userJson),
      tokens: AuthTokens.fromJson(tokensJson),
    );
  }
}

/// Result of M03 (register). The live backend registers the account and
/// immediately sends an OTP to verify it — it does NOT hand back a session
/// (no `user`/`tokens`), so registration always continues into the OTP
/// screen rather than logging the user in directly. `otp` is only present
/// on non-production backends (it's the code itself, for testing without a
/// real SMS gateway) and is otherwise absent.
class RegisterResult {
  final String message;
  final String subjectId;
  final String role;
  final String? debugOtp;

  const RegisterResult({
    required this.message,
    required this.subjectId,
    required this.role,
    this.debugOtp,
  });

  factory RegisterResult.fromJson(Map<String, dynamic> json) {
    return RegisterResult(
      message: json['message'] as String? ?? '',
      subjectId: json['subjectId']?.toString() ?? '',
      role: json['role'] as String? ?? 'user',
      debugOtp: json['otp'] as String?,
    );
  }
}

class OtpRequestResult {
  final int otpExpiresInSeconds;
  final int resendCooldownSeconds;

  /// Only present on non-production backends — see [RegisterResult.debugOtp].
  final String? debugOtp;

  const OtpRequestResult({
    required this.otpExpiresInSeconds,
    required this.resendCooldownSeconds,
    this.debugOtp,
  });

  factory OtpRequestResult.fromJson(Map<String, dynamic> json) {
    return OtpRequestResult(
      otpExpiresInSeconds: (json['otpExpiresInSeconds'] as num?)?.toInt() ?? 300,
      resendCooldownSeconds: (json['resendCooldownSeconds'] as num?)?.toInt() ?? 60,
      debugOtp: json['otp'] as String?,
    );
  }
}
