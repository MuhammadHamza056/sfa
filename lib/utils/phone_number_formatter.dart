import 'package:flutter/services.dart';

class PhoneInputValidator {
  /// Validates phone number based on country dialing code.
  /// For Kuwait (+965), phone number must be exactly 8 digits.
  static String? validatePhoneNumber(String? value, String countryCode) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter phone number';
    }

    final cleanDigits = value.replaceAll(RegExp(r'\D'), '');

    if (countryCode == '+965' || countryCode == '965' || countryCode == 'KW') {
      if (cleanDigits.length != 8) {
        return 'Kuwait phone number must be exactly 8 digits';
      }
    } else if (countryCode == '+966' || countryCode == '966' || countryCode == 'SA') {
      if (cleanDigits.length != 9) {
        return 'Saudi phone number must be exactly 9 digits';
      }
    } else {
      if (cleanDigits.length < 7 || cleanDigits.length > 12) {
        return 'Please enter a valid phone number';
      }
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
