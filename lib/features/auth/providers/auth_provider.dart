import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/hive_services.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_result.dart';
import '../../../utils/phone_number_formatter.dart';
import '../data/auth_models.dart';
import '../data/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ApiClient.instance);
});

enum AuthStatus {
  initial,
  loading,

  /// OTP has been sent (M01) and the UI should move to the OTP screen.
  otpSent,

  /// OTP verified / login succeeded — tokens are saved, session is live.
  authenticated,
  failure,
}

class AuthState {
  final String phoneNumber;
  final String dialCode;
  final String countryCode;
  final int maxPhoneLength;
  final bool isEmailMode;
  final AuthStatus status;
  final String? errorMessage;
  final String? phoneValidationError;

  final bool registerAsMerchant;
  final bool agreeTerms;

  final AuthUser? user;

  /// Only ever set on non-production backends that echo the OTP straight
  /// back in the response — see [RegisterResult.debugOtp]. Lets the OTP
  /// screen prefill itself so testing doesn't need a real SMS.
  final String? debugOtp;

  /// The `type` M02 verify needs. The backend only recognizes
  /// `SIGNUP_VERIFY` and `FORGOT_PASSWORD` — there's no separate login
  /// type, so [AuthNotifier.submitLogin] reuses `SIGNUP_VERIFY` just like
  /// [AuthNotifier.submitSignup] does.
  final String otpPurpose;

  const AuthState({
    this.phoneNumber = '',
    this.dialCode = '+965',
    this.countryCode = 'KW',
    this.maxPhoneLength = 8,
    this.isEmailMode = false,
    this.status = AuthStatus.initial,
    this.registerAsMerchant = false,
    this.agreeTerms = false,
    this.errorMessage,
    this.phoneValidationError,
    this.user,
    this.debugOtp,
    this.otpPurpose = 'SIGNUP_VERIFY',
  });

  AuthState copyWith({
    String? phoneNumber,
    String? dialCode,
    String? countryCode,
    int? maxPhoneLength,
    bool? isEmailMode,
    AuthStatus? status,
    bool? registerAsMerchant,
    bool? agreeTerms,
    String? errorMessage,
    String? phoneValidationError,
    AuthUser? user,
    String? debugOtp,
    String? otpPurpose,
  }) {
    return AuthState(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      dialCode: dialCode ?? this.dialCode,
      countryCode: countryCode ?? this.countryCode,
      maxPhoneLength: maxPhoneLength ?? this.maxPhoneLength,
      isEmailMode: isEmailMode ?? this.isEmailMode,
      status: status ?? this.status,
      registerAsMerchant: registerAsMerchant ?? this.registerAsMerchant,
      agreeTerms: agreeTerms ?? this.agreeTerms,
      errorMessage: errorMessage,
      phoneValidationError: phoneValidationError,
      user: user ?? this.user,
      debugOtp: debugOtp,
      otpPurpose: otpPurpose ?? this.otpPurpose,
    );
  }
}

/// Replaces the old `AuthBloc`. Login/signup each wrap themselves in their
/// own `.autoDispose` scope the way they used to each get their own
/// `BlocProvider(create: (context) => AuthBloc())` — the state resets
/// whenever neither screen is watching it anymore.
class AuthNotifier extends AutoDisposeNotifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  AuthRepository get _repository => ref.read(authRepositoryProvider);

  void changePhone(String phoneNumber) {
    final validationError = PhoneInputValidator.validatePhoneNumber(
      phoneNumber,
      state.dialCode,
    );
    state = state.copyWith(
      phoneNumber: phoneNumber,
      phoneValidationError: validationError,
    );
  }

  void changeCountryCode({
    required String countryCode,
    required String dialCode,
    required int phoneLength,
  }) {
    final validationError = PhoneInputValidator.validatePhoneNumber(
      state.phoneNumber,
      dialCode,
    );
    state = state.copyWith(
      countryCode: countryCode,
      dialCode: dialCode,
      maxPhoneLength: phoneLength,
      phoneValidationError: validationError,
    );
  }

  void toggleAuthMode(bool isEmailMode) {
    state = state.copyWith(isEmailMode: isEmailMode);
  }

  void toggleRegisterAsMerchant(bool registerAsMerchant) {
    state = state.copyWith(registerAsMerchant: registerAsMerchant);
  }

  void toggleAgreeTerms(bool agreeTerms) {
    state = state.copyWith(agreeTerms: agreeTerms);
  }

  /// M01 — kicks off the phone-OTP login flow used by the login screen's
  /// phone mode. Success moves the UI to the OTP screen, not straight in.
  Future<void> submitLogin() async {
    final error = PhoneInputValidator.validatePhoneNumber(
      state.phoneNumber,
      state.dialCode,
    );
    if (error != null) {
      state = state.copyWith(
        phoneValidationError: error,
        status: AuthStatus.failure,
        errorMessage: error,
      );
      return;
    }

    state = state.copyWith(status: AuthStatus.loading);
    final result = await _repository.sendOtp(
      countryCode: state.dialCode,
      phoneNumber: state.phoneNumber,
    );
    result.when(
      success: (otp) => state = state.copyWith(
        status: AuthStatus.otpSent,
        debugOtp: otp.debugOtp,
        otpPurpose: 'SIGNUP_VERIFY',
      ),
      failure: (error) => state = state.copyWith(
        status: AuthStatus.failure,
        errorMessage: error.message,
      ),
    );
  }

  /// M04 — email/password login (the login screen's email mode).
  Future<void> loginWithPassword({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);
    final result = await _repository.login(email: email, password: password);
    await _handleSessionResult(result);
  }

  /// M03 — creates the account; the backend sends the verification OTP as
  /// part of registration itself, so success here moves straight to the
  /// OTP screen (see [RegisterResult]).
  Future<void> submitSignup({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    if (name.trim().isEmpty ||
        email.trim().isEmpty ||
        password.isEmpty ||
        password != confirmPassword ||
        !state.agreeTerms) {
      state = state.copyWith(
        status: AuthStatus.failure,
        errorMessage: password != confirmPassword
            ? 'Passwords do not match'
            : !state.agreeTerms
            ? 'Please agree to the Terms & Conditions'
            : 'Please fill all required fields',
      );
      return;
    }
    final phoneError = PhoneInputValidator.validatePhoneNumber(
      state.phoneNumber,
      state.dialCode,
    );
    if (phoneError != null) {
      state = state.copyWith(
        phoneValidationError: phoneError,
        status: AuthStatus.failure,
        errorMessage: phoneError,
      );
      return;
    }

    state = state.copyWith(status: AuthStatus.loading);
    final registerResult = await _repository.register(
      name: name,
      email: email,
      password: password,
      countryCode: state.dialCode,
      phoneNumber: state.phoneNumber,
    );

    // Registration already triggers the OTP send server-side — unlike
    // submitLogin, there's no separate sendOtp call here (that would
    // request a second, redundant code).
    registerResult.when(
      success: (register) => state = state.copyWith(
        status: AuthStatus.otpSent,
        debugOtp: register.debugOtp,
        otpPurpose: 'SIGNUP_VERIFY',
      ),
      failure: (error) => state = state.copyWith(
        status: AuthStatus.failure,
        errorMessage: error.message,
      ),
    );
  }

  /// M02 — verifies the code sent by [submitLogin]/[submitSignup] and, on
  /// success, persists the session so the app treats the user as logged in.
  Future<void> verifyOtp(String otp) async {
    state = state.copyWith(status: AuthStatus.loading);
    final result = await _repository.verifyOtp(
      countryCode: state.dialCode,
      phoneNumber: state.phoneNumber,
      otp: otp,
      type: state.otpPurpose,
    );
    await _handleSessionResult(result);
  }

  /// M03
  Future<void> resendOtp() async {
    final result = await _repository.resendOtp(
      countryCode: state.dialCode,
      phoneNumber: state.phoneNumber,
      type: state.otpPurpose,
    );
    result.when(
      success: (_) {},
      failure: (error) =>
          state = state.copyWith(status: AuthStatus.failure, errorMessage: error.message),
    );
  }

  Future<void> _handleSessionResult(ApiResult<AuthSession> result) async {
    final session = result.dataOrNull;
    if (session == null) {
      state = state.copyWith(
        status: AuthStatus.failure,
        errorMessage: result.errorOrNull?.message,
      );
      return;
    }
    await SecureStorage.putAccessToken(session.tokens.accessToken);
    await SecureStorage.putRefreshToken(session.tokens.refreshToken);
    state = state.copyWith(status: AuthStatus.authenticated, user: session.user);
  }

  /// M08
  Future<void> logout() async {
    await _repository.logout();
    await SecureStorage.clearSession();
    state = const AuthState();
  }
}

final authProvider = NotifierProvider.autoDispose<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
