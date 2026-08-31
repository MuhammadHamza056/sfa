import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../utils/phone_number_formatter.dart';

enum AuthStatus { initial, loading, success, failure }

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

    // Simulate authentication API call
    await Future.delayed(const Duration(seconds: 2));

    state = state.copyWith(status: AuthStatus.success);
  }

  void toggleRegisterAsMerchant(bool registerAsMerchant) {
    state = state.copyWith(registerAsMerchant: registerAsMerchant);
  }

  void toggleAgreeTerms(bool agreeTerms) {
    state = state.copyWith(agreeTerms: agreeTerms);
  }
}

final authProvider = NotifierProvider.autoDispose<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
