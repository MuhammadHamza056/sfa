import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../hive_services.dart';

class AppLocalizations {
  final Locale locale;
  Map<String, String> _localizedStrings = {};

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  bool get isArabic => locale.languageCode == 'ar';

  Future<bool> load() async {
    try {
      String jsonString = await rootBundle.loadString('lib/l10n/app_${locale.languageCode}.arb');
      Map<String, dynamic> jsonMap = json.decode(jsonString);

      _localizedStrings = {};
      jsonMap.forEach((key, value) {
        if (!key.startsWith('@')) {
          _localizedStrings[key] = value.toString();
        }
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['ar', 'en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

class LocaleNotifier extends ValueNotifier<Locale> {
  LocaleNotifier(super.value);

  void toggleLanguage() {
    setLocale(value.languageCode == 'ar' ? const Locale('en') : const Locale('ar'));
  }

  /// Reads the persisted locale. Safe to call before [SecureStorage.init]
  /// has completed — it simply falls back to the default locale.
  void loadFromStorage() {
    final saved = SecureStorage.getSavedLocale();
    if (saved != null) {
      value = Locale(saved);
    }
  }

  /// Applies [newLocale] and persists it for the next launch.
  void setLocale(Locale newLocale) {
    value = newLocale;
    SecureStorage.putSavedLocale(newLocale.languageCode);
  }
}

final localeNotifier = LocaleNotifier(const Locale('ar'));
