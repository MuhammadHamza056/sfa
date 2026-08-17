import 'package:flutter/foundation.dart';

@immutable
abstract class AuthEvent {
  const AuthEvent();
}

class PhoneChangedEvent extends AuthEvent {
  final String phoneNumber;
  const PhoneChangedEvent(this.phoneNumber);
}

class CountryCodeChangedEvent extends AuthEvent {
  final String countryCode;
  final String dialCode;
  final int phoneLength;

  const CountryCodeChangedEvent({
    required this.countryCode,
    required this.dialCode,
    required this.phoneLength,
  });
}

class ToggleAuthModeEvent extends AuthEvent {
  final bool isEmailMode;
  const ToggleAuthModeEvent({required this.isEmailMode});
}

class SubmitLoginEvent extends AuthEvent {
  const SubmitLoginEvent();
}

class ToggleRegisterAsMerchantEvent extends AuthEvent {
  final bool registerAsMerchant;
  const ToggleRegisterAsMerchantEvent({required this.registerAsMerchant});
}

class ToggleAgreeTermsEvent extends AuthEvent {
  final bool agreeTerms;
  const ToggleAgreeTermsEvent({required this.agreeTerms});
}
