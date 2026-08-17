import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../utils/phone_number_formatter.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(const AuthState()) {
    on<PhoneChangedEvent>(_onPhoneChanged);
    on<CountryCodeChangedEvent>(_onCountryCodeChanged);
    on<ToggleAuthModeEvent>(_onToggleAuthMode);
    on<SubmitLoginEvent>(_onSubmitLogin);
    on<ToggleRegisterAsMerchantEvent>(_onToggleRegisterAsMerchant);
    on<ToggleAgreeTermsEvent>(_onToggleAgreeTerms);
  }

  void _onPhoneChanged(PhoneChangedEvent event, Emitter<AuthState> emit) {
    final validationError = PhoneInputValidator.validatePhoneNumber(
      event.phoneNumber,
      state.dialCode,
    );
    emit(state.copyWith(
      phoneNumber: event.phoneNumber,
      phoneValidationError: validationError,
    ));
  }

  void _onCountryCodeChanged(
    CountryCodeChangedEvent event,
    Emitter<AuthState> emit,
  ) {
    final validationError = PhoneInputValidator.validatePhoneNumber(
      state.phoneNumber,
      event.dialCode,
    );
    emit(state.copyWith(
      countryCode: event.countryCode,
      dialCode: event.dialCode,
      maxPhoneLength: event.phoneLength,
      phoneValidationError: validationError,
    ));
  }

  void _onToggleAuthMode(ToggleAuthModeEvent event, Emitter<AuthState> emit) {
    emit(state.copyWith(isEmailMode: event.isEmailMode));
  }

  Future<void> _onSubmitLogin(
    SubmitLoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    final error = PhoneInputValidator.validatePhoneNumber(
      state.phoneNumber,
      state.dialCode,
    );

    if (error != null) {
      emit(state.copyWith(
        phoneValidationError: error,
        status: AuthStatus.failure,
        errorMessage: error,
      ));
      return;
    }

    emit(state.copyWith(status: AuthStatus.loading));

    // Simulate authentication API call
    await Future.delayed(const Duration(seconds: 2));

    emit(state.copyWith(
      status: AuthStatus.success,
    ));
  }

  void _onToggleRegisterAsMerchant(
    ToggleRegisterAsMerchantEvent event,
    Emitter<AuthState> emit,
  ) {
    emit(state.copyWith(registerAsMerchant: event.registerAsMerchant));
  }

  void _onToggleAgreeTerms(
    ToggleAgreeTermsEvent event,
    Emitter<AuthState> emit,
  ) {
    emit(state.copyWith(agreeTerms: event.agreeTerms));
  }
}
