/// SharedPreferences / secure-storage key catalog.
///
/// Centralizing keys prevents typos and makes settings migrations discoverable.
abstract final class StorageKeys {
  // ── Theme & locale ──────────────────────────────────────────────────────
  static const String themeMode = 'theme_mode';
  static const String themeVariant = 'theme_variant';
  static const String localeCode = 'locale_code';

  // ── Active profile ──────────────────────────────────────────────────────
  static const String activeProfileId = 'active_profile_id';

  // ── Currency (also mirrored on Profile; this is the last-used display) ──
  static const String currencyCode = 'currency_code';

  // ── Backup metadata (SRS §20.13) ────────────────────────────────────────
  static const String lastBackupAt = 'last_backup_at';
  static const String lastBackupSizeBytes = 'last_backup_size_bytes';
  static const String autoBackupEnabled = 'auto_backup_enabled';
  static const String lastBackupStatus = 'last_backup_status';

  // ── Update checks ───────────────────────────────────────────────────────
  static const String autoUpdateCheckEnabled = 'auto_update_check_enabled';
  static const String lastUpdateCheckAt = 'last_update_check_at';
  static const String updateCheckFrequencyHours = 'update_check_frequency_hours';
  static const String updateHistory = 'update_history';

  // ── Notifications ───────────────────────────────────────────────────────
  static const String notificationsEnabled = 'notifications_enabled';
  static const String budgetAlertsEnabled = 'budget_alerts_enabled';
  static const String reminderAlertsEnabled = 'reminder_alerts_enabled';

  // ── App lock ────────────────────────────────────────────────────────────
  static const String appLockEnabled = 'app_lock_enabled';
  static const String biometricEnabled = 'biometric_enabled';
  static const String lockTimeoutMinutes = 'lock_timeout_minutes';

  // ── Secure storage only (never SharedPreferences) ───────────────────────
  static const String pinHash = 'pin_hash';
  static const String pinSalt = 'pin_salt';
  static const String googleAuthTokens = 'google_auth_tokens';

  // ── First-run / onboarding ──────────────────────────────────────────────
  static const String hasCompletedOnboarding = 'has_completed_onboarding';
  static const String databaseInitialized = 'database_initialized';
  static const String lastBackgroundAt = 'last_background_at';
}
