import 'package:flutter/material.dart';

/// Semantic colour tokens for the app, resolved per [ThemeMode].
///
/// Widgets should read colours through `context.palette` rather than reaching
/// for [AppColors] directly, so the same widget renders correctly in both the
/// light and dark themes. [AppColors] remains the source of the raw brand
/// values that these tokens are built from.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  /// Scaffold / page background.
  final Color background;

  /// Page background for screens that sit on a faint grey wash in the light
  /// theme. Collapses onto [background] in dark, where the design keeps every
  /// page on the same maroon.
  final Color backgroundSubtle;

  /// Cards, inputs and list surfaces sitting directly on [background].
  final Color surface;

  /// Raised surfaces that need to separate from [surface] — membership pills,
  /// the bottom navigation bar, selected chips.
  final Color surfaceAlt;

  /// Warm off-white panels — the navigation drawer.
  final Color surfaceWarm;

  /// Soft neutral fills (image placeholders, disabled inputs, grey blocks).
  final Color surfaceMuted;

  /// Brand gold. Identical in both themes.
  final Color primary;

  /// Content drawn on top of [primary] — button labels and icons.
  final Color onPrimary;

  /// Primary body and heading text.
  final Color textPrimary;

  /// Supporting text that still needs full legibility.
  final Color textSecondary;

  /// De-emphasised text: hints, timestamps, helper copy.
  final Color textMuted;

  /// Hairline dividers between list rows.
  final Color divider;

  /// Container outlines and input borders.
  final Color border;

  /// High-contrast outline for ghost buttons — the social sign-in row.
  final Color outlineStrong;

  /// Default icon colour for monochrome glyphs.
  final Color icon;

  /// Positive / confirmation states.
  final Color success;

  /// Errors and destructive actions.
  final Color danger;

  /// Drop shadow colour for elevated containers.
  final Color shadow;

  const AppPalette({
    required this.background,
    required this.backgroundSubtle,
    required this.surface,
    required this.surfaceAlt,
    required this.surfaceWarm,
    required this.surfaceMuted,
    required this.primary,
    required this.onPrimary,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.divider,
    required this.border,
    required this.outlineStrong,
    required this.icon,
    required this.success,
    required this.danger,
    required this.shadow,
  });

  /// Deep brand maroon. The light theme's text colour and, per the design,
  /// the dark theme's page background.
  static const Color _maroon = Color(0xff451425);
  static const Color _plum = Color(0xff51063C);
  static const Color _gold = Color(0xffCA9A4E);

  /// Primary text on a surface that stays light in both themes.
  static const Color lightTextPrimary = _maroon;

  static const AppPalette light = AppPalette(
    background: Colors.white,
    backgroundSubtle: Color(0xffF6F6F6),
    surface: Colors.white,
    surfaceAlt: Color(0xffFAF8F5),
    surfaceWarm: Color(0xffF5F0EA),
    surfaceMuted: Color(0xffF6F6F6),
    primary: _gold,
    onPrimary: Colors.white,
    textPrimary: _maroon,
    textSecondary: _plum,
    textMuted: Color(0x80451425),
    divider: Color(0x4051063C),
    border: Color(0x40CA9A4E),
    outlineStrong: _maroon,
    icon: _maroon,
    success: Color(0xff08A385),
    danger: Color(0xffF30000),
    shadow: Color(0x14000000),
  );

  static const AppPalette dark = AppPalette(
    background: _maroon,
    backgroundSubtle: _maroon,
    surface: _maroon,
    surfaceAlt: Color(0xff582C3B),
    surfaceWarm: Color(0xff582C3B),
    surfaceMuted: Color(0xff5C3140),
    primary: _gold,
    onPrimary: Colors.white,
    textPrimary: Colors.white,
    textSecondary: Color(0xffE8D5B6),
    textMuted: Color(0x99FFFFFF),
    divider: Color(0x33FFFFFF),
    border: Color(0x40CA9A4E),
    outlineStrong: Color(0x33FFFFFF),
    icon: Colors.white,
    success: Color(0xff08A385),
    danger: Color(0xffF30000),
    shadow: Color(0x33000000),
  );

  @override
  AppPalette copyWith({
    Color? background,
    Color? backgroundSubtle,
    Color? surface,
    Color? surfaceAlt,
    Color? surfaceWarm,
    Color? surfaceMuted,
    Color? primary,
    Color? onPrimary,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? divider,
    Color? border,
    Color? outlineStrong,
    Color? icon,
    Color? success,
    Color? danger,
    Color? shadow,
  }) {
    return AppPalette(
      background: background ?? this.background,
      backgroundSubtle: backgroundSubtle ?? this.backgroundSubtle,
      surface: surface ?? this.surface,
      surfaceAlt: surfaceAlt ?? this.surfaceAlt,
      surfaceWarm: surfaceWarm ?? this.surfaceWarm,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      divider: divider ?? this.divider,
      border: border ?? this.border,
      outlineStrong: outlineStrong ?? this.outlineStrong,
      icon: icon ?? this.icon,
      success: success ?? this.success,
      danger: danger ?? this.danger,
      shadow: shadow ?? this.shadow,
    );
  }

  @override
  AppPalette lerp(covariant AppPalette? other, double t) {
    if (other == null) return this;
    return AppPalette(
      background: Color.lerp(background, other.background, t)!,
      backgroundSubtle: Color.lerp(
        backgroundSubtle,
        other.backgroundSubtle,
        t,
      )!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceAlt: Color.lerp(surfaceAlt, other.surfaceAlt, t)!,
      surfaceWarm: Color.lerp(surfaceWarm, other.surfaceWarm, t)!,
      surfaceMuted: Color.lerp(surfaceMuted, other.surfaceMuted, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      border: Color.lerp(border, other.border, t)!,
      outlineStrong: Color.lerp(outlineStrong, other.outlineStrong, t)!,
      icon: Color.lerp(icon, other.icon, t)!,
      success: Color.lerp(success, other.success, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
    );
  }
}

extension AppPaletteX on BuildContext {
  /// The semantic colour set for the active theme.
  AppPalette get palette =>
      Theme.of(this).extension<AppPalette>() ?? AppPalette.light;

  /// Whether the dark theme is currently active.
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}
