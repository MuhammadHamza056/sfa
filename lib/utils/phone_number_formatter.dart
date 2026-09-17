import 'package:flutter/services.dart';

/// ISO codes for the Gulf countries this app delivers in — the only
/// options the country pickers ([GulfCountryCodePicker]) expose.
const List<String> gulfCountryIsoCodes = ['KW', 'SA', 'AE', 'QA', 'BH', 'OM'];

/// Local subscriber number length (digits after the dial code) for each
/// Gulf country's mobile numbers. Used to both cap what can be typed and
/// to validate on submit, so the two always agree.
const Map<String, int> gulfPhoneLengths = {
  '+965': 8, // Kuwait
  '+966': 9, // Saudi Arabia
  '+971': 9, // UAE
  '+974': 8, // Qatar
  '+973': 8, // Bahrain
  '+968': 8, // Oman
};

class PhoneInputValidator {
  /// Validates a phone number against the expected local length for its
  /// dial code. Dial codes outside [gulfPhoneLengths] (shouldn't occur
  /// once the picker is restricted to Gulf countries, but covers any
  /// caller that passes a raw/unrecognized code) fall back to a loose
  /// 7-12 digit sanity check.
  static String? validatePhoneNumber(String? value, String countryCode) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter phone number';
    }

    final cleanDigits = value.replaceAll(RegExp(r'\D'), '');
    final expectedLength = gulfPhoneLengths[countryCode];

    if (expectedLength != null) {
      if (cleanDigits.length != expectedLength) {
        return 'Phone number must be exactly $expectedLength digits';
      }
    } else if (cleanDigits.length < 7 || cleanDigits.length > 12) {
      return 'Please enter a valid phone number';
    }

    return null;
  }
}

class PhoneInputFormatter extends TextInputFormatter {
  final int maxLength;

  PhoneInputFormatter({this.maxLength = 8});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final newText = newValue.text.replaceAll(RegExp(r'\D'), '');

    if (newText.length > maxLength) {
      return oldValue;
    }

    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
