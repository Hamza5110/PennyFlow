import 'package:flutter/material.dart';

/// User-configurable settings options (SRS §13.19).
abstract final class SettingsConstants {
  static const List<String> supportedCurrencyCodes = [
    'PKR',
    'USD',
    'EUR',
    'GBP',
    'INR',
    'AED',
    'SAR',
  ];

  static const List<({String code, String labelKey})> supportedLocales = [
    (code: 'en', labelKey: 'settings_language_en'),
    (code: 'ur', labelKey: 'settings_language_ur'),
  ];

  static const List<({ThemeMode mode, String labelKey})> themeOptions = [
    (mode: ThemeMode.system, labelKey: 'settings_theme_system'),
    (mode: ThemeMode.light, labelKey: 'settings_theme_light'),
    (mode: ThemeMode.dark, labelKey: 'settings_theme_dark'),
  ];

  static const List<({int minutes, String labelKey})> lockTimeoutOptions = [
    (minutes: 0, labelKey: 'security_lock_timeout_immediate'),
    (minutes: 1, labelKey: 'security_lock_timeout_1m'),
    (minutes: 5, labelKey: 'security_lock_timeout_5m'),
    (minutes: 15, labelKey: 'security_lock_timeout_15m'),
    (minutes: 30, labelKey: 'security_lock_timeout_30m'),
  ];
}
