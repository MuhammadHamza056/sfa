import 'package:flutter/services.dart';

class CustomNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;
    return RegExp(r'^(?!00$|0$)\d*\.?\d*$').hasMatch(text)
        ? newValue
        : oldValue;
  }
}

class TextFormatter {
  static List<TextInputFormatter>? numberandalphabets = [
    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9 ]')),
  ];

  static List<TextInputFormatter>? numbersOnlyWithoutZeros = [
    CustomNumberInputFormatter(),
  ];

  static List<TextInputFormatter>? numbersOnly = [
    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
  ];

  static List<TextInputFormatter>? roundNumberOnly = [
    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
  ];
  static List<TextInputFormatter>? alphabetsOnly = [
    FilteringTextInputFormatter.deny(RegExp(r'[^a-zA-Z\s ]')),
  ];

  static List<TextInputFormatter>? alphanumeric = [
    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
  ];

  static List<TextInputFormatter>? numbersAndDoubleOnly = [
    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
  ];

  static List<TextInputFormatter>? numberAndDash = [
    FilteringTextInputFormatter.allow(RegExp(r'[0-9\-]')),
  ];

  static List<TextInputFormatter>? alphanumericWithSpecialCharacters = [
    FilteringTextInputFormatter.allow(
        RegExp(r'[a-zA-Z0-9!@#$%^&*(),.?":{}|<>]')),
  ];

  static List<TextInputFormatter> characterLength(int? maxLength) {
    return [LengthLimitingTextInputFormatter(maxLength)];
  }

  static List<TextInputFormatter>? capitalWord = [
    TextInputFormatter.withFunction((oldValue, newValue) {
      if (newValue.text.isNotEmpty) {
        if (newValue.text.length > 20) {
          return oldValue;
        }
        String capitalized =
            newValue.text[0].toUpperCase() + newValue.text.substring(1);
        return newValue.copyWith(
          text: capitalized,
          selection: TextSelection.collapsed(offset: capitalized.length),
        );
      }
      return newValue;
    }),
  ];
}
