import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/settings_constants.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../controllers/settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'settings_title'.tr,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionHeader(title: 'settings_appearance'.tr),
          Card(
            child: Column(
              children: [
                Obx(
                  () => ListTile(
                    leading: const Icon(Icons.brightness_6_outlined),
                    title: Text('settings_theme'.tr),
                    subtitle: Text(controller.themeLabel(controller.themeMode.value)),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _pickTheme(context),
                  ),
                ),
                const Divider(height: 1),
                Obx(
                  () => ListTile(
                    leading: const Icon(Icons.language_rounded),
                    title: Text('settings_language'.tr),
                    subtitle: Text(controller.localeLabel(controller.localeCode.value)),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _pickLanguage(context),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SectionHeader(title: 'settings_regional'.tr),
          Card(
            child: Obx(
              () => ListTile(
                leading: const Icon(Icons.payments_outlined),
                title: Text('settings_currency'.tr),
                subtitle: Text(controller.currencyCode.value),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => _pickCurrency(context),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _SectionHeader(title: 'settings_notifications'.tr),
          Card(
            child: Column(
              children: [
                Obx(
                  () => SwitchListTile(
                    secondary: const Icon(Icons.notifications_outlined),
                    title: Text('settings_notifications_master'.tr),
                    subtitle: Text('settings_notifications_master_subtitle'.tr),
                    value: controller.notificationsEnabled.value,
                    onChanged: controller.setNotifications,
                  ),
                ),
                const Divider(height: 1),
                Obx(
                  () => SwitchListTile(
                    title: Text('settings_budget_alerts'.tr),
                    value: controller.budgetAlertsEnabled.value,
                    onChanged: controller.notificationsEnabled.value
                        ? controller.setBudgetAlerts
                        : null,
                  ),
                ),
                Obx(
                  () => SwitchListTile(
                    title: Text('settings_reminder_alerts'.tr),
                    value: controller.reminderAlertsEnabled.value,
                    onChanged: controller.notificationsEnabled.value
                        ? controller.setReminderAlerts
                        : null,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SectionHeader(title: 'settings_backup_section'.tr),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.cloud_sync_outlined),
                  title: Text('backup_title'.tr),
                  subtitle: Text('settings_backup_subtitle'.tr),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: controller.openBackup,
                ),
                const Divider(height: 1),
                Obx(
                  () => SwitchListTile(
                    title: Text('backup_auto'.tr),
                    subtitle: Text('backup_auto_subtitle'.tr),
                    value: controller.autoBackupEnabled.value,
                    onChanged: controller.setAutoBackup,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SectionHeader(title: 'settings_data_section'.tr),
          Card(
            child: Obx(
              () => Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.upload_file_outlined),
                    title: Text('settings_export'.tr),
                    subtitle: Text('settings_export_subtitle'.tr),
                    onTap: controller.isLoading.value
                        ? null
                        : controller.exportData,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.download_outlined),
                    title: Text('settings_import'.tr),
                    subtitle: Text('settings_import_subtitle'.tr),
                    onTap: controller.isLoading.value
                        ? null
                        : controller.importData,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _SectionHeader(title: 'settings_updates_section'.tr),
          Card(
            child: Column(
              children: [
                Obx(
                  () => SwitchListTile(
                    secondary: const Icon(Icons.system_update_outlined),
                    title: Text('settings_auto_update_check'.tr),
                    subtitle: Text('settings_auto_update_check_subtitle'.tr),
                    value: controller.autoUpdateCheckEnabled.value,
                    onChanged: controller.setAutoUpdateCheck,
                  ),
                ),
                const Divider(height: 1),
                Obx(
                  () => ListTile(
                    leading: const Icon(Icons.download_for_offline_outlined),
                    title: Text('settings_check_updates'.tr),
                    subtitle: Text('settings_check_updates_subtitle'.tr),
                    onTap: controller.isLoading.value
                        ? null
                        : controller.checkForUpdates,
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.history_rounded),
                  title: Text('update_history_title'.tr),
                  subtitle: Text('settings_update_history_subtitle'.tr),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: controller.openUpdateHistory,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SectionHeader(title: 'settings_about_section'.tr),
          Card(
            child: Column(
              children: [
                Obx(
                  () => ListTile(
                    leading: const Icon(Icons.info_outline_rounded),
                    title: Text('settings_version'.tr),
                    subtitle: Text(
                      'settings_version_value'.trParams({
                        'version': controller.appVersion.value,
                        'build': controller.buildNumber.value,
                      }),
                    ),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.article_outlined),
                  title: Text('settings_about'.tr),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: controller.openAbout,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: Text('settings_privacy'.tr),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: controller.openPrivacy,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickTheme(BuildContext context) async {
    final selected = await showModalBottomSheet<ThemeMode>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final option in SettingsConstants.themeOptions)
              ListTile(
                title: Text(option.labelKey.tr),
                trailing: controller.themeMode.value == option.mode
                    ? const Icon(Icons.check_rounded)
                    : null,
                onTap: () => Navigator.pop(context, option.mode),
              ),
          ],
        ),
      ),
    );
    if (selected != null) await controller.setThemeMode(selected);
  }

  Future<void> _pickLanguage(BuildContext context) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final option in SettingsConstants.supportedLocales)
              ListTile(
                title: Text(option.labelKey.tr),
                trailing: controller.localeCode.value == option.code
                    ? const Icon(Icons.check_rounded)
                    : null,
                onTap: () => Navigator.pop(context, option.code),
              ),
          ],
        ),
      ),
    );
    if (selected != null) await controller.setLocale(selected);
  }

  Future<void> _pickCurrency(BuildContext context) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final code in SettingsConstants.supportedCurrencyCodes)
              ListTile(
                title: Text(code),
                trailing: controller.currencyCode.value == code
                    ? const Icon(Icons.check_rounded)
                    : null,
                onTap: () => Navigator.pop(context, code),
              ),
          ],
        ),
      ),
    );
    if (selected != null) await controller.updateCurrency(selected);
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}
