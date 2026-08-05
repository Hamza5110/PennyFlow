import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography system — Plus Jakarta Sans for UI, JetBrains Mono for amounts.
abstract final class AppTypography {
  static String get fontFamily => GoogleFonts.plusJakartaSans().fontFamily!;

  static String get monoFamily => GoogleFonts.jetBrainsMono().fontFamily!;

  static TextTheme textTheme(Brightness brightness) {
    final base = brightness == Brightness.dark
        ? ThemeData.dark().textTheme
        : ThemeData.light().textTheme;

    final jakarta = GoogleFonts.plusJakartaSansTextTheme(base);

    return jakarta.copyWith(
      displayLarge: jakarta.displayLarge?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -1.2,
      ),
      displayMedium: jakarta.displayMedium?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
      ),
      headlineLarge: jakarta.headlineLarge?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      headlineMedium: jakarta.headlineMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: jakarta.headlineSmall?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      titleLarge: jakarta.titleLarge?.copyWith(fontWeight: FontWeight.w600),
      titleMedium: jakarta.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      titleSmall: jakarta.titleSmall?.copyWith(fontWeight: FontWeight.w600),
      bodyLarge: jakarta.bodyLarge?.copyWith(height: 1.45),
      bodyMedium: jakarta.bodyMedium?.copyWith(height: 1.45),
      bodySmall: jakarta.bodySmall?.copyWith(height: 1.4),
      labelLarge: jakarta.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
    );
  }

  /// Monospace style for monetary amounts — tabular figures feel.
  static TextStyle money({
    required Color color,
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.w600,
  }) {
    return GoogleFonts.jetBrainsMono(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: -0.3,
      height: 1.2,
    );
  }
}
