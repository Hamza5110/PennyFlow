import 'package:flutter/material.dart';

import '../../app/theme/app_theme_variant.dart';

/// User-configurable settings options (SRS §13.19).
abstract final class SettingsConstants {
  static const List<({String code, String labelKey, String symbol})>
      currencyOptions = [
    (code: 'PKR', labelKey: 'currency_pkr', symbol: '₨'),
    (code: 'USD', labelKey: 'currency_usd', symbol: '\$'),
    (code: 'EUR', labelKey: 'currency_eur', symbol: '€'),
    (code: 'GBP', labelKey: 'currency_gbp', symbol: '£'),
    (code: 'INR', labelKey: 'currency_inr', symbol: '₹'),
    (code: 'AED', labelKey: 'currency_aed', symbol: 'د.إ'),
    (code: 'SAR', labelKey: 'currency_sar', symbol: '﷼'),
  ];

  static List<String> get supportedCurrencyCodes =>
      currencyOptions.map((o) => o.code).toList();

  static const List<({String code, String labelKey})> supportedLocales = [
    (code: 'en', labelKey: 'settings_language_en'),
    (code: 'ur', labelKey: 'settings_language_ur'),
  ];

  static const List<({ThemeMode mode, String labelKey, IconData icon})>
      themeModeOptions = [
    (
      mode: ThemeMode.system,
      labelKey: 'settings_theme_system',
      icon: Icons.brightness_auto_rounded,
    ),
    (
      mode: ThemeMode.light,
      labelKey: 'settings_theme_light',
      icon: Icons.light_mode_rounded,
    ),
    (
      mode: ThemeMode.dark,
      labelKey: 'settings_theme_dark',
      icon: Icons.dark_mode_rounded,
    ),
  ];

  static List<AppThemeVariant> get themeVariants => AppThemeVariant.values;

  static const List<({int minutes, String labelKey})> lockTimeoutOptions = [
    (minutes: 0, labelKey: 'security_lock_timeout_immediate'),
    (minutes: 1, labelKey: 'security_lock_timeout_1m'),
    (minutes: 5, labelKey: 'security_lock_timeout_5m'),
    (minutes: 15, labelKey: 'security_lock_timeout_15m'),
    (minutes: 30, labelKey: 'security_lock_timeout_30m'),
  ];
}
