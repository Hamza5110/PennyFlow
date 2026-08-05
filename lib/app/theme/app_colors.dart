import 'package:flutter/material.dart';

/// Brand + semantic color tokens for PennyFlow (Material 3).
///
/// Direction: calm teal-green finance palette — trustworthy, not generic
/// purple or cream/terracotta. Light and dark schemes share the same seeds.
abstract final class AppColors {
  // ── Brand seeds ─────────────────────────────────────────────────────────
  static const Color seed = Color(0xFF0F766E); // teal-700
  static const Color seedSecondary = Color(0xFF334155); // slate-700
  static const Color seedTertiary = Color(0xFFB45309); // amber-700 accent

  // ── Explicit brand tokens (use when ColorScheme is not enough) ──────────
  static const Color brandPrimary = Color(0xFF0F766E);
  static const Color brandPrimaryLight = Color(0xFF14B8A6);
  static const Color brandPrimaryDark = Color(0xFF115E59);
  static const Color brandSecondary = Color(0xFF1E293B);

  // ── Semantic money colors ───────────────────────────────────────────────
  static const Color income = Color(0xFF059669); // emerald-600
  static const Color expense = Color(0xFFDC2626); // red-600
  static const Color pending = Color(0xFFD97706); // amber-600
  static const Color transfer = Color(0xFF2563EB); // blue-600

  // ── Budget progress ─────────────────────────────────────────────────────
  static const Color budgetNormal = Color(0xFF059669);
  static const Color budgetWarning = Color(0xFFD97706);
  static const Color budgetExceeded = Color(0xFFDC2626);

  // ── Surfaces (light) ────────────────────────────────────────────────────
  static const Color lightBackground = Color(0xFFF8FAFC); // slate-50
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF1F5F9); // slate-100
  static const Color lightOutline = Color(0xFFCBD5E1); // slate-300

  // ── Surfaces (dark) ─────────────────────────────────────────────────────
  static const Color darkBackground = Color(0xFF0B1220);
  static const Color darkSurface = Color(0xFF111827);
  static const Color darkSurfaceVariant = Color(0xFF1F2937);
  static const Color darkOutline = Color(0xFF374151);

  // ── Neutral text helpers ────────────────────────────────────────────────
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);

  static Color budgetStatusColor(double spentRatio) {
    if (spentRatio >= 1.0) return budgetExceeded;
    if (spentRatio >= 0.8) return budgetWarning;
    return budgetNormal;
  }
}
