import 'package:flutter_test/flutter_test.dart';
import 'package:sfa/features/auth/bloc/auth_bloc.dart';
import 'package:sfa/features/auth/bloc/auth_event.dart';
import 'package:sfa/features/auth/bloc/auth_state.dart';
import 'package:sfa/utils/phone_number_formatter.dart';

void main() {
  group('PhoneInputValidator Tests', () {
    test('Kuwait (+965) phone validation - 8 digits required', () {
      expect(PhoneInputValidator.validatePhoneNumber('1234567', '+965'), isNotNull);
      expect(PhoneInputValidator.validatePhoneNumber('12345678', '+965'), isNull);
      expect(PhoneInputValidator.validatePhoneNumber('123456789', '+965'), isNotNull);
    });

    test('Saudi (+966) phone validation - 9 digits required', () {
      expect(PhoneInputValidator.validatePhoneNumber('12345678', '+966'), isNotNull);
      expect(PhoneInputValidator.validatePhoneNumber('123456789', '+966'), isNull);
    });
  });

  group('AuthBloc Tests', () {
    late AuthBloc authBloc;

    setUp(() {
      authBloc = AuthBloc();
    });

    tearDown(() {
      authBloc.close();
    });

    test('Initial state defaults to Kuwait (+965) with 8 digit limit', () {
      expect(authBloc.state.dialCode, equals('+965'));
      expect(authBloc.state.countryCode, equals('KW'));
      expect(authBloc.state.maxPhoneLength, equals(8));
    });

    test('Emits updated state on phone number change', () {
      authBloc.add(const PhoneChangedEvent('91234567'));
      expect(
        authBloc.stream,
        emitsThrough(predicate<AuthState>(
          (state) => state.phoneNumber == '91234567' && state.phoneValidationError == null,
        )),
      );
    });
  });
}
