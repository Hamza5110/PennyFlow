import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_theme_variant.dart';
import '../../../core/base/base_controller.dart';
import '../../../core/constants/settings_constants.dart';
import '../../../core/errors/error_handler.dart';
import '../../../services/profile/profile_service.dart';
import '../../../services/reminder/reminder_service.dart';
import '../../../services/security/app_lock_service.dart';
import '../../../services/settings/data_transfer_service.dart';
import '../../../services/settings/settings_service.dart';
import '../../../services/update/update_service.dart';
import '../widgets/pin_entry_sheet.dart';
import '../widgets/pin_setup_sheet.dart';

class SettingsController extends BaseController {
  SettingsController(
    this._settings,
    this._profiles,
    this._dataTransfer,
    this._update,
    this._appLock,
  );

  final SettingsService _settings;
  final ProfileService _profiles;
  final DataTransferService _dataTransfer;
  final UpdateService _update;
  final AppLockService _appLock;

  final RxString appVersion = ''.obs;
  final RxString buildNumber = ''.obs;
  final RxBool biometricAvailable = false.obs;

  Rx<ThemeMode> get themeMode => _settings.themeMode;
  Rx<AppThemeVariant> get themeVariant => _settings.themeVariant;
  RxString get localeCode => _settings.localeCode;
  RxString get currencyCode => _settings.currencyCode;
  RxBool get autoBackupEnabled => _settings.autoBackupEnabled;
  RxBool get autoUpdateCheckEnabled => _settings.autoUpdateCheckEnabled;
  RxBool get notificationsEnabled => _settings.notificationsEnabled;
  RxBool get budgetAlertsEnabled => _settings.budgetAlertsEnabled;
  RxBool get reminderAlertsEnabled => _settings.reminderAlertsEnabled;
  RxBool get appLockEnabled => _settings.appLockEnabled;
  RxBool get biometricEnabled => _settings.biometricEnabled;
  RxInt get lockTimeoutMinutes => _settings.lockTimeoutMinutes;

  @override
  void onInit() {
    super.onInit();
    _loadAppInfo();
    _loadBiometricAvailability();
  }

  Future<void> _loadBiometricAvailability() async {
    biometricAvailable.value = await _appLock.isBiometricAvailable();
  }

  Future<void> _loadAppInfo() async {
    final info = await PackageInfo.fromPlatform();
    appVersion.value = info.version;
    buildNumber.value = info.buildNumber;
  }

  Future<void> setThemeMode(ThemeMode mode) => _settings.setThemeMode(mode);

  Future<void> setThemeVariant(AppThemeVariant variant) =>
      _settings.setThemeVariant(variant);

  void openThemePicker() => Get.toNamed<void>(AppRoutes.themePicker);

  void openLanguagePicker() => Get.toNamed<void>(AppRoutes.languagePicker);

  void openCurrencyPicker() => Get.toNamed<void>(AppRoutes.currencyPicker);

  void openLockTimeoutPicker() =>
      Get.toNamed<void>(AppRoutes.lockTimeoutPicker);

  Future<void> setLocale(String code) => _settings.setLocaleCode(code);

  Future<void> updateCurrency(String code) async {
    await _settings.setCurrencyCode(code);
    await _profiles.updateActiveProfileCurrency(code);
  }

  Future<void> setAutoBackup(bool enabled) =>
      _settings.setAutoBackupEnabled(enabled);

  Future<void> setAutoUpdateCheck(bool enabled) =>
      _settings.setAutoUpdateCheckEnabled(enabled);

  Future<void> setNotifications(bool enabled) async {
    await _settings.setNotificationsEnabled(enabled);
    await _applyReminderAlertPreference();
  }

  Future<void> setBudgetAlerts(bool enabled) =>
      _settings.setBudgetAlertsEnabled(enabled);

  Future<void> setReminderAlerts(bool enabled) async {
    await _settings.setReminderAlertsEnabled(enabled);
    await _applyReminderAlertPreference();
  }

  Future<void> _applyReminderAlertPreference() async {
    if (!Get.isRegistered<ReminderService>()) return;
    await Get.find<ReminderService>().applyAlertPreference();
  }

  Future<void> setAppLock(bool enabled) async {
    if (enabled) {
      final pin = await PinSetupSheet.show();
      if (pin == null) return;

      await runGuarded(() async {
        final result = await _appLock.enableAppLock(pin: pin);
        if (result.success) {
          ErrorHandler.showSuccess('security_app_lock_enabled'.tr);
        } else if (result.userMessage != null) {
          ErrorHandler.showError(result.userMessage!);
        }
      });
      return;
    }

    final pin = await PinEntrySheet.show(
      title: 'security_enter_current_pin'.tr,
      subtitle: 'security_disable_lock_hint'.tr,
    );
    if (pin == null) return;

    await runGuarded(() async {
      final result = await _appLock.disableAppLock(pin: pin);
      if (result.success) {
        ErrorHandler.showSuccess('security_app_lock_disabled'.tr);
      } else if (result.userMessage != null) {
        ErrorHandler.showError(result.userMessage!);
      }
    });
  }

  Future<void> setBiometric(bool enabled) async {
    if (!biometricAvailable.value) {
      ErrorHandler.showError('security_biometric_unavailable'.tr);
      return;
    }
    if (!appLockEnabled.value) {
      ErrorHandler.showError('security_enable_lock_first'.tr);
      return;
    }

    if (enabled) {
      final result = await _appLock.authenticateWithBiometric();
      if (!result.success) {
        if (result.errorCode == 'BIOMETRIC_CANCELLED') return;
        if (result.userMessage != null && result.userMessage!.isNotEmpty) {
          ErrorHandler.showError(result.userMessage!);
        }
        return;
      }
    }

    await _settings.setBiometricEnabled(enabled);
    await _appLock.syncBiometricToProfile(enabled);
  }

  Future<void> changePin() async {
    if (!appLockEnabled.value) {
      ErrorHandler.showError('security_enable_lock_first'.tr);
      return;
    }

    final currentPin = await PinEntrySheet.show(
      title: 'security_enter_current_pin'.tr,
      subtitle: 'security_change_pin_hint'.tr,
    );
    if (currentPin == null) return;

    final valid = await _appLock.verifyPin(currentPin);
    if (!valid) {
      ErrorHandler.showError('security_pin_incorrect'.tr);
      return;
    }

    final newPin = await PinSetupSheet.show(
      title: 'security_create_pin'.tr,
      subtitle: 'security_pin_hint'.tr,
    );
    if (newPin == null) return;

    await runGuarded(() async {
      final result = await _appLock.changePin(
        currentPin: currentPin,
        newPin: newPin,
      );
      if (result.success) {
        ErrorHandler.showSuccess('security_pin_changed'.tr);
      } else if (result.userMessage != null) {
        ErrorHandler.showError(result.userMessage!);
      }
    });
  }

  Future<void> setLockTimeout(int minutes) =>
      _settings.setLockTimeoutMinutes(minutes);

  String lockTimeoutLabel(int minutes) {
    final option = SettingsConstants.lockTimeoutOptions.firstWhere(
      (item) => item.minutes == minutes,
      orElse: () => SettingsConstants.lockTimeoutOptions[2],
    );
    return option.labelKey.tr;
  }

  void openBackup() => Get.toNamed<void>(AppRoutes.backup);

  void openAbout() => Get.toNamed<void>(AppRoutes.about);

  void openPrivacy() => Get.toNamed<void>(AppRoutes.privacy);

  void openLicenses() => Get.toNamed<void>(AppRoutes.licenses);

  void openUpdate() => Get.toNamed<void>(AppRoutes.update);

  void openUpdateHistory() => Get.toNamed<void>(AppRoutes.updateHistory);

  Future<void> checkForUpdates() async {
    await runGuarded(() async {
      final result = await _update.checkForUpdate(manual: true);
      if (!result.success) {
        if (result.userMessage != null) {
          ErrorHandler.showError(result.userMessage!);
        }
        return;
      }
      if (result.data == null) {
        ErrorHandler.showSuccess('update_up_to_date'.tr);
        return;
      }
      openUpdate();
    });
  }

  Future<void> exportData() async {
    await runGuarded(() async {
      final result = await _dataTransfer.exportData();
      if (!result.success || result.data == null) {
        if (result.userMessage != null) {
          ErrorHandler.showError(result.userMessage!);
        }
        return;
      }
      final shareResult = await _dataTransfer.shareExport(result.data!);
      if (shareResult.success) {
        ErrorHandler.showSuccess('settings_export_success'.tr);
      } else if (shareResult.userMessage != null) {
        ErrorHandler.showError(shareResult.userMessage!);
      }
    });
  }

  Future<void> importData() async {
    await runGuarded(() async {
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: Text('settings_import_confirm_title'.tr),
          content: Text('settings_import_confirm_message'.tr),
          actions: [
            TextButton(
              onPressed: () => Get.back<bool>(result: false),
              child: Text('common_cancel'.tr),
            ),
            TextButton(
              onPressed: () => Get.back<bool>(result: true),
              child: Text('settings_import_confirm_action'.tr),
            ),
          ],
        ),
      );
      if (confirmed != true) return;

      final result = await _dataTransfer.importData(overwrite: true);
      if (result.success) {
        ErrorHandler.showSuccess('settings_import_success'.tr);
      } else if (result.userMessage != null) {
        ErrorHandler.showError(result.userMessage!);
      }
    });
  }

  String themeLabel(ThemeMode mode) {
    final option = SettingsConstants.themeModeOptions.firstWhere(
      (item) => item.mode == mode,
      orElse: () => SettingsConstants.themeModeOptions.first,
    );
    return option.labelKey.tr;
  }

  String themeVariantLabel(AppThemeVariant variant) => variant.labelKey.tr;

  String currencyLabel(String code) {
    final option = SettingsConstants.currencyOptions.firstWhere(
      (item) => item.code == code,
      orElse: () => SettingsConstants.currencyOptions.first,
    );
    return '${option.labelKey.tr} (${option.code})';
  }

  String localeLabel(String code) {
    final option = SettingsConstants.supportedLocales.firstWhere(
      (item) => item.code == code,
      orElse: () => SettingsConstants.supportedLocales.first,
    );
    return option.labelKey.tr;
  }
}
