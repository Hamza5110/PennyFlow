import 'package:flutter/material.dart';

/// Named color palettes — each variant provides distinct light and dark themes.
enum AppThemeVariant {
  teal,
  ocean,
  forest,
  royal,
  sunset,
  rose;

  String get labelKey => switch (this) {
        AppThemeVariant.teal => 'theme_variant_teal',
        AppThemeVariant.ocean => 'theme_variant_ocean',
        AppThemeVariant.forest => 'theme_variant_forest',
        AppThemeVariant.royal => 'theme_variant_royal',
        AppThemeVariant.sunset => 'theme_variant_sunset',
        AppThemeVariant.rose => 'theme_variant_rose',
      };

  Color get seedColor => switch (this) {
        AppThemeVariant.teal => const Color(0xFF0F766E),
        AppThemeVariant.ocean => const Color(0xFF1D4ED8),
        AppThemeVariant.forest => const Color(0xFF15803D),
        AppThemeVariant.royal => const Color(0xFF6D28D9),
        AppThemeVariant.sunset => const Color(0xFFC2410C),
        AppThemeVariant.rose => const Color(0xFFE11D48),
      };

  Color get secondaryColor => switch (this) {
        AppThemeVariant.teal => const Color(0xFF334155),
        AppThemeVariant.ocean => const Color(0xFF0E7490),
        AppThemeVariant.forest => const Color(0xFF365314),
        AppThemeVariant.royal => const Color(0xFF4F46E5),
        AppThemeVariant.sunset => const Color(0xFFB45309),
        AppThemeVariant.rose => const Color(0xFFBE185D),
      };

  Color get tertiaryColor => switch (this) {
        AppThemeVariant.teal => const Color(0xFFB45309),
        AppThemeVariant.ocean => const Color(0xFF7C3AED),
        AppThemeVariant.forest => const Color(0xFFCA8A04),
        AppThemeVariant.royal => const Color(0xFFDB2777),
        AppThemeVariant.sunset => const Color(0xFFDC2626),
        AppThemeVariant.rose => const Color(0xFFF97316),
      };

  /// Accent shown on theme preview cards.
  Color previewAccent(Brightness brightness) {
    if (brightness == Brightness.dark) {
      return Color.lerp(seedColor, Colors.white, 0.35)!;
    }
    return seedColor;
  }

  static AppThemeVariant fromStorage(String? raw) {
    return AppThemeVariant.values.firstWhere(
      (v) => v.name == raw,
      orElse: () => AppThemeVariant.teal,
    );
  }
}
