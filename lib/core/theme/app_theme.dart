import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_palette.dart';
import 'theme_notifier.dart';

/// Builds the light and dark [ThemeData] from an [AppPalette].
///
/// Both themes share the brand gold and the Cairo type ramp; only the surface
/// and text roles differ. Text styles are given their colour here so that
/// widgets relying on the inherited `DefaultTextStyle` follow the theme
/// automatically.
class AppTheme {
  const AppTheme._();

  static final ThemeData light = _build(AppPalette.light, Brightness.light);

  static final ThemeData dark = _build(AppPalette.dark, Brightness.dark);

  static ThemeData _build(AppPalette palette, Brightness brightness) {
    final base = ThemeData(brightness: brightness, useMaterial3: true);

    final textTheme = GoogleFonts.cairoTextTheme(
      base.textTheme,
    ).apply(bodyColor: palette.textPrimary, displayColor: palette.textPrimary);

    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: palette.primary,
        brightness: brightness,
        primary: palette.primary,
        onPrimary: palette.onPrimary,
        surface: palette.surface,
        onSurface: palette.textPrimary,
        error: palette.danger,
      ),
      scaffoldBackgroundColor: palette.background,
      canvasColor: palette.background,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      iconTheme: IconThemeData(color: palette.icon),
      dividerColor: palette.divider,
      dividerTheme: DividerThemeData(color: palette.divider),
      appBarTheme: AppBarTheme(
        backgroundColor: palette.background,
        foregroundColor: palette.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: palette.icon),
        titleTextStyle: textTheme.titleLarge,
        systemOverlayStyle: systemOverlayStyle(brightness == Brightness.dark),
      ),
      cardTheme: CardThemeData(
        color: palette.surface,
        surfaceTintColor: Colors.transparent,
        shadowColor: palette.shadow,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: palette.surface,
        selectedItemColor: palette.primary,
        unselectedItemColor: palette.textMuted,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: palette.background,
        surfaceTintColor: Colors.transparent,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: palette.background,
        surfaceTintColor: Colors.transparent,
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: palette.background,
        surfaceTintColor: Colors.transparent,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: palette.icon,
        textColor: palette.textPrimary,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: const WidgetStatePropertyAll(Colors.white),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? palette.success
              : palette.surfaceMuted,
        ),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: palette.primary,
        linearTrackColor: palette.surfaceMuted,
      ),
      extensions: <ThemeExtension<dynamic>>[palette],
    );
  }
}
