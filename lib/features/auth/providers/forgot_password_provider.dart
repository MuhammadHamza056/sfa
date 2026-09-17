import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../utils/phone_number_formatter.dart';
import '../data/auth_repository.dart';
import 'auth_provider.dart';

enum ForgotPasswordStatus {
  initial,
  loading,

  /// Reset OTP has been sent (M10) — the UI should move to the OTP screen.
  otpSent,

  /// OTP verified (M02 w/ type=FORGOT_PASSWORD) — [ForgotPasswordState.resetToken]
  /// is set and the UI should move to the new-password screen.
  otpVerified,

  /// Password reset (M11) — the UI should return to login.
  success,
  failure,
}

class ForgotPasswordState {
  final bool isEmailMode;
  final String email;
  final String phoneNumber;
  final String dialCode;
  final String countryCode;
  final String? phoneValidationError;
  final ForgotPasswordStatus status;
  final String? errorMessage;

  /// Only set on non-production backends that echo the OTP back — see
  /// [AuthState.debugOtp].
  final String? debugOtp;

  /// Returned by the OTP-verify step; consumed by the final reset call.
  final String? resetToken;

  const ForgotPasswordState({
    this.isEmailMode = true,
    this.email = '',
    this.phoneNumber = '',
    this.dialCode = '+965',
    this.countryCode = 'KW',
    this.phoneValidationError,
    this.status = ForgotPasswordStatus.initial,
    this.errorMessage,
    this.debugOtp,
    this.resetToken,
  });

  ForgotPasswordState copyWith({
    bool? isEmailMode,
    String? email,
    String? phoneNumber,
    String? dialCode,
    String? countryCode,
    String? phoneValidationError,
    ForgotPasswordStatus? status,
    String? errorMessage,
    String? debugOtp,
    String? resetToken,
  }) {
    return ForgotPasswordState(
      isEmailMode: isEmailMode ?? this.isEmailMode,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      dialCode: dialCode ?? this.dialCode,
      countryCode: countryCode ?? this.countryCode,
      phoneValidationError: phoneValidationError,
      status: status ?? this.status,
      errorMessage: errorMessage,
      debugOtp: debugOtp ?? this.debugOtp,
      resetToken: resetToken ?? this.resetToken,
    );
  }
}

/// M10/M02/M11 — request a reset OTP, verify it, then set the new password.
/// Deliberately separate from [AuthNotifier]: this flow never issues a
/// session, so it must not share the "authenticated" status the login/OTP
/// screens use to store tokens and navigate into the app.
class ForgotPasswordNotifier extends AutoDisposeNotifier<ForgotPasswordState> {
  @override
  ForgotPasswordState build() => const ForgotPasswordState();

  AuthRepository get _repository => ref.read(authRepositoryProvider);

  void toggleMode(bool isEmailMode) {
    state = state.copyWith(isEmailMode: isEmailMode);
  }

  void changeEmail(String email) {
    state = state.copyWith(email: email);
  }

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

  void changeCountryCode({required String countryCode, required String dialCode}) {
    final validationError = PhoneInputValidator.validatePhoneNumber(
      state.phoneNumber,
      dialCode,
    );
    state = state.copyWith(
      countryCode: countryCode,
      dialCode: dialCode,
      phoneValidationError: validationError,
    );
  }

  /// M10 — also used to resend the code (the endpoint just re-sends).
  Future<void> requestReset() async {
    if (state.isEmailMode) {
      if (state.email.trim().isEmpty) {
        state = state.copyWith(
          status: ForgotPasswordStatus.failure,
          errorMessage: 'Please enter your email address',
        );
        return;
      }
    } else {
      final error = PhoneInputValidator.validatePhoneNumber(
        state.phoneNumber,
        state.dialCode,
      );
      if (error != null) {
        state = state.copyWith(
          phoneValidationError: error,
          status: ForgotPasswordStatus.failure,
          errorMessage: error,
        );
        return;
      }
    }

    state = state.copyWith(status: ForgotPasswordStatus.loading);
    final result = await _repository.forgotPasswordRequest(
      email: state.isEmailMode ? state.email.trim() : null,
      countryCode: state.isEmailMode ? null : state.dialCode,
      phoneNumber: state.isEmailMode ? null : state.phoneNumber,
    );
    result.when(
      success: (otp) => state = state.copyWith(
        status: ForgotPasswordStatus.otpSent,
        debugOtp: otp.debugOtp,
      ),
      failure: (error) => state = state.copyWith(
        status: ForgotPasswordStatus.failure,
        errorMessage: error.message,
      ),
    );
  }

  Future<void> verifyOtp(String otp) async {
    state = state.copyWith(status: ForgotPasswordStatus.loading);
    final result = await _repository.verifyPasswordResetOtp(
      email: state.isEmailMode ? state.email.trim() : null,
      countryCode: state.isEmailMode ? null : state.dialCode,
      phoneNumber: state.isEmailMode ? null : state.phoneNumber,
      otp: otp,
    );
    result.when(
      success: (resetToken) => state = state.copyWith(
        status: ForgotPasswordStatus.otpVerified,
        resetToken: resetToken,
      ),
      failure: (error) => state = state.copyWith(
        status: ForgotPasswordStatus.failure,
        errorMessage: error.message,
      ),
    );
  }

  Future<void> resetPassword(String newPassword) async {
    final resetToken = state.resetToken;
    if (resetToken == null) {
      state = state.copyWith(
        status: ForgotPasswordStatus.failure,
        errorMessage: 'Reset session expired, please request a new code',
      );
      return;
    }

    state = state.copyWith(status: ForgotPasswordStatus.loading);
    final result = await _repository.forgotPasswordReset(
      resetToken: resetToken,
      newPassword: newPassword,
    );
    result.when(
      success: (_) => state = state.copyWith(status: ForgotPasswordStatus.success),
      failure: (error) => state = state.copyWith(
        status: ForgotPasswordStatus.failure,
        errorMessage: error.message,
      ),
    );
  }
}

final forgotPasswordProvider =
    NotifierProvider.autoDispose<ForgotPasswordNotifier, ForgotPasswordState>(
      ForgotPasswordNotifier.new,
    );
