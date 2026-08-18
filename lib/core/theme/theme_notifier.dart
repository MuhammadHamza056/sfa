import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../hive_services.dart';

/// Holds the active [ThemeMode] for the whole app.
///
/// Mirrors the [localeNotifier] pattern used for language switching: a single
/// top-level notifier that [MyApp] listens to, so changing the theme rebuilds
/// `MaterialApp` without disturbing the navigation stack.
class ThemeNotifier extends ValueNotifier<ThemeMode> {
  ThemeNotifier(super.value);

  bool get isDarkMode => value == ThemeMode.dark;

  /// Reads the persisted preference. Safe to call before [SecureStorage.init]
  /// has completed — it simply falls back to the light theme.
  void loadFromStorage() {
    value = SecureStorage.getDarkMode() ? ThemeMode.dark : ThemeMode.light;
    _applySystemOverlay();
  }

  /// Applies [isDark] and persists it for the next launch.
  void setDarkMode(bool isDark) {
    value = isDark ? ThemeMode.dark : ThemeMode.light;
    SecureStorage.putDarkMode(isDark);
    _applySystemOverlay();
  }

  /// Keeps the status bar glyphs readable against the page behind them.
  void _applySystemOverlay() {
    SystemChrome.setSystemUIOverlayStyle(systemOverlayStyle(isDarkMode));
  }

  void toggleTheme() => setDarkMode(!isDarkMode);
}

/// Status bar styling for a given brightness. Shared with [AppBarTheme] so
/// screens with and without an app bar agree.
SystemUiOverlayStyle systemOverlayStyle(bool isDark) => SystemUiOverlayStyle(
  statusBarColor: Colors.transparent,
  // Android
  statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
  // iOS
  statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
);

final themeNotifier = ThemeNotifier(ThemeMode.light);
