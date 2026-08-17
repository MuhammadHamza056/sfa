import 'package:flutter/foundation.dart';

enum AuthStatus { initial, loading, success, failure }

@immutable
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
