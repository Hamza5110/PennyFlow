import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/base/base_service.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/storage_keys.dart';
import '../../data/models/enums/app_enums.dart';
import '../storage/local_storage_service.dart';

/// Reactive settings facade over [LocalStorageService].
///
/// Controllers observe [themeMode], [localeCode], [currencyCode], etc.
/// Business features must not write SharedPreferences directly.
class SettingsService extends GetxService with BaseService {
  SettingsService(this._storage);

  final LocalStorageService _storage;

  final Rx<ThemeMode> themeMode = ThemeMode.system.obs;
  final RxString localeCode = 'en'.obs;
  final RxString currencyCode = AppConstants.defaultCurrencyCode.obs;
  final RxBool autoBackupEnabled = false.obs;
  final RxBool autoUpdateCheckEnabled = true.obs;
  final RxBool notificationsEnabled = true.obs;
  final RxBool budgetAlertsEnabled = true.obs;
  final RxBool reminderAlertsEnabled = true.obs;
  final Rxn<DateTime> lastBackupAt = Rxn<DateTime>();
  final RxnInt lastBackupSizeBytes = RxnInt();
  final Rx<BackupStatus> lastBackupStatus = BackupStatus.idle.obs;
  final RxBool appLockEnabled = false.obs;
  final RxBool biometricEnabled = false.obs;
  final RxInt lockTimeoutMinutes = 5.obs;
  final RxBool isSessionUnlocked = true.obs;

  Future<SettingsService> init() async {
    themeMode.value = _readThemeMode();
    localeCode.value = _storage.getString(StorageKeys.localeCode) ?? 'en';
    currencyCode.value = _storage.getString(StorageKeys.currencyCode) ??
        AppConstants.defaultCurrencyCode;
    autoBackupEnabled.value =
        _storage.getBoolOr(StorageKeys.autoBackupEnabled, false);
    autoUpdateCheckEnabled.value =
        _storage.getBoolOr(StorageKeys.autoUpdateCheckEnabled, true);
    notificationsEnabled.value =
        _storage.getBoolOr(StorageKeys.notificationsEnabled, true);
    budgetAlertsEnabled.value =
        _storage.getBoolOr(StorageKeys.budgetAlertsEnabled, true);
    reminderAlertsEnabled.value =
        _storage.getBoolOr(StorageKeys.reminderAlertsEnabled, true);

    final backupIso = _storage.getString(StorageKeys.lastBackupAt);
    if (backupIso != null) {
      lastBackupAt.value = DateTime.tryParse(backupIso);
    }
    lastBackupSizeBytes.value =
        _storage.getInt(StorageKeys.lastBackupSizeBytes);

    final statusName = _storage.getString(StorageKeys.lastBackupStatus);
    if (statusName != null) {
      lastBackupStatus.value = BackupStatus.values.firstWhere(
        (e) => e.name == statusName,
        orElse: () => BackupStatus.idle,
      );
    }

    appLockEnabled.value =
        _storage.getBoolOr(StorageKeys.appLockEnabled, false);
    biometricEnabled.value =
        _storage.getBoolOr(StorageKeys.biometricEnabled, false);
    lockTimeoutMinutes.value =
        _storage.getIntOr(StorageKeys.lockTimeoutMinutes, 5);
    isSessionUnlocked.value = !appLockEnabled.value;

    log.i('SettingsService loaded');
    return this;
  }

  ThemeMode _readThemeMode() {
    final raw = _storage.getString(StorageKeys.themeMode);
    switch (raw) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    themeMode.value = mode;
    final value = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await _storage.setString(StorageKeys.themeMode, value);
    Get.changeThemeMode(mode);
  }

  Future<void> setLocaleCode(String code) async {
    localeCode.value = code;
    await _storage.setString(StorageKeys.localeCode, code);
    final locale = code == 'ur' ? const Locale('ur', 'PK') : Locale(code);
    await Get.updateLocale(locale);
  }

  Future<void> setCurrencyCode(String code) async {
    currencyCode.value = code.toUpperCase();
    await _storage.setString(StorageKeys.currencyCode, currencyCode.value);
  }

  Future<void> setAutoBackupEnabled(bool enabled) async {
    autoBackupEnabled.value = enabled;
    await _storage.setBool(StorageKeys.autoBackupEnabled, enabled);
  }

  Future<void> setAutoUpdateCheckEnabled(bool enabled) async {
    autoUpdateCheckEnabled.value = enabled;
    await _storage.setBool(StorageKeys.autoUpdateCheckEnabled, enabled);
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    notificationsEnabled.value = enabled;
    await _storage.setBool(StorageKeys.notificationsEnabled, enabled);
  }

  Future<void> setBudgetAlertsEnabled(bool enabled) async {
    budgetAlertsEnabled.value = enabled;
    await _storage.setBool(StorageKeys.budgetAlertsEnabled, enabled);
  }

  Future<void> setReminderAlertsEnabled(bool enabled) async {
    reminderAlertsEnabled.value = enabled;
    await _storage.setBool(StorageKeys.reminderAlertsEnabled, enabled);
  }

  int get updateCheckFrequencyHours =>
      _storage.getIntOr(StorageKeys.updateCheckFrequencyHours, 24);

  DateTime? get lastUpdateCheckAt {
    final raw = _storage.getString(StorageKeys.lastUpdateCheckAt);
    return raw == null ? null : DateTime.tryParse(raw);
  }

  bool get isUpdateCheckDue {
    final last = lastUpdateCheckAt;
    if (last == null) return true;
    return DateTime.now().difference(last) >=
        Duration(hours: updateCheckFrequencyHours);
  }

  Future<void> recordUpdateCheck({required DateTime at}) async {
    await _storage.setString(StorageKeys.lastUpdateCheckAt, at.toIso8601String());
  }

  Future<void> recordBackupMeta({
    required DateTime at,
    required int sizeBytes,
    required BackupStatus status,
  }) async {
    lastBackupAt.value = at;
    lastBackupSizeBytes.value = sizeBytes;
    lastBackupStatus.value = status;
    await _storage.setString(StorageKeys.lastBackupAt, at.toIso8601String());
    await _storage.setInt(StorageKeys.lastBackupSizeBytes, sizeBytes);
    await _storage.setString(StorageKeys.lastBackupStatus, status.name);
  }

  bool get hasCompletedOnboarding =>
      _storage.getBoolOr(StorageKeys.hasCompletedOnboarding, false);

  Future<void> setOnboardingCompleted({bool value = true}) =>
      _storage.setBool(StorageKeys.hasCompletedOnboarding, value);

  int? get activeProfileId => _storage.getInt(StorageKeys.activeProfileId);

  Future<void> setActiveProfileId(int id) =>
      _storage.setInt(StorageKeys.activeProfileId, id);

  bool get isAppLockEnabled => appLockEnabled.value;

  Future<void> setAppLockEnabled(bool enabled) async {
    appLockEnabled.value = enabled;
    await _storage.setBool(StorageKeys.appLockEnabled, enabled);
    if (!enabled) {
      await setBiometricEnabled(false);
      unlockSession();
    } else {
      lockSession();
    }
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    biometricEnabled.value = enabled;
    await _storage.setBool(StorageKeys.biometricEnabled, enabled);
  }

  Future<void> setLockTimeoutMinutes(int minutes) async {
    lockTimeoutMinutes.value = minutes;
    await _storage.setInt(StorageKeys.lockTimeoutMinutes, minutes);
  }

  void lockSession() => isSessionUnlocked.value = false;

  void unlockSession() {
    isSessionUnlocked.value = true;
    unawaited(_storage.remove(StorageKeys.lastBackgroundAt));
  }

  /// Returns true when background duration exceeds the configured timeout.
  bool shouldLockAfterBackground() {
    if (!isAppLockEnabled) return false;

    final raw = _storage.getString(StorageKeys.lastBackgroundAt);
    if (raw == null) return false;

    final lastBackground = DateTime.tryParse(raw);
    if (lastBackground == null) return false;

    final timeoutMinutes = lockTimeoutMinutes.value;
    if (timeoutMinutes <= 0) return true;

    final timeout = Duration(minutes: timeoutMinutes);
    return DateTime.now().difference(lastBackground) >= timeout;
  }
}
