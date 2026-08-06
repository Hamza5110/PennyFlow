import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/base/base_controller.dart';
import '../../../core/constants/settings_constants.dart';
import '../../../core/errors/error_handler.dart';
import '../../../services/profile/profile_service.dart';
import '../../../services/settings/data_transfer_service.dart';
import '../../../services/settings/settings_service.dart';
import '../../../services/update/update_service.dart';

class SettingsController extends BaseController {
  SettingsController(
    this._settings,
    this._profiles,
    this._dataTransfer,
    this._update,
  );

  final SettingsService _settings;
  final ProfileService _profiles;
  final DataTransferService _dataTransfer;
  final UpdateService _update;

  final RxString appVersion = ''.obs;
  final RxString buildNumber = ''.obs;

  Rx<ThemeMode> get themeMode => _settings.themeMode;
  RxString get localeCode => _settings.localeCode;
  RxString get currencyCode => _settings.currencyCode;
  RxBool get autoBackupEnabled => _settings.autoBackupEnabled;
  RxBool get autoUpdateCheckEnabled => _settings.autoUpdateCheckEnabled;
  RxBool get notificationsEnabled => _settings.notificationsEnabled;
  RxBool get budgetAlertsEnabled => _settings.budgetAlertsEnabled;
  RxBool get reminderAlertsEnabled => _settings.reminderAlertsEnabled;

  @override
  void onInit() {
    super.onInit();
    _loadAppInfo();
  }

  Future<void> _loadAppInfo() async {
    final info = await PackageInfo.fromPlatform();
    appVersion.value = info.version;
    buildNumber.value = info.buildNumber;
  }

  Future<void> setThemeMode(ThemeMode mode) => _settings.setThemeMode(mode);

  Future<void> setLocale(String code) => _settings.setLocaleCode(code);

  Future<void> updateCurrency(String code) async {
    await _settings.setCurrencyCode(code);
    await _profiles.updateActiveProfileCurrency(code);
  }

  Future<void> setAutoBackup(bool enabled) =>
      _settings.setAutoBackupEnabled(enabled);

  Future<void> setAutoUpdateCheck(bool enabled) =>
      _settings.setAutoUpdateCheckEnabled(enabled);

  Future<void> setNotifications(bool enabled) =>
      _settings.setNotificationsEnabled(enabled);

  Future<void> setBudgetAlerts(bool enabled) =>
      _settings.setBudgetAlertsEnabled(enabled);

  Future<void> setReminderAlerts(bool enabled) =>
      _settings.setReminderAlertsEnabled(enabled);

  void openBackup() => Get.toNamed<void>(AppRoutes.backup);

  void openAbout() => Get.toNamed<void>(AppRoutes.about);

  void openPrivacy() => Get.toNamed<void>(AppRoutes.privacy);

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
    final option = SettingsConstants.themeOptions.firstWhere(
      (item) => item.mode == mode,
      orElse: () => SettingsConstants.themeOptions.first,
    );
    return option.labelKey.tr;
  }

  String localeLabel(String code) {
    final option = SettingsConstants.supportedLocales.firstWhere(
      (item) => item.code == code,
      orElse: () => SettingsConstants.supportedLocales.first,
    );
    return option.labelKey.tr;
  }
}
