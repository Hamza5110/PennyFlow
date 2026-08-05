import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_loading_indicator.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../data/models/backup/backup_manifest.dart';
import '../controllers/backup_controller.dart';

class BackupView extends GetView<BackupController> {
  const BackupView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppScaffold(
      title: 'backup_title'.tr,
      body: Obx(() {
        if (controller.isLoading.value && controller.progress.value == null) {
          return AppLoadingIndicator(message: 'common_loading'.tr);
        }

        final progress = controller.progress.value;
        final isRunning = progress != null &&
            progress.phase != BackupPhase.idle &&
            controller.isRunning.value;

        return RefreshIndicator(
          onRefresh: controller.loadRemoteMeta,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (!controller.isSignedIn) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'backup_sign_in_required'.tr,
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        AppButton(
                          label: 'auth_sign_in_google'.tr,
                          onPressed: controller.openSignIn,
                          icon: Icons.login_rounded,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'backup_status_title'.tr,
                        style: theme.textTheme.titleSmall,
                      ),
                      const SizedBox(height: 12),
                      _InfoRow(
                        label: 'backup_last_backup'.tr,
                        value: controller.lastBackupAt.value == null
                            ? 'backup_never'.tr
                            : AppFormatters.dateTime(
                                controller.lastBackupAt.value!,
                              ),
                      ),
                      _InfoRow(
                        label: 'backup_size'.tr,
                        value: controller.formatSize(
                          controller.lastBackupSizeBytes.value,
                        ),
                      ),
                      _InfoRow(
                        label: 'backup_status_label'.tr,
                        value: controller.statusLabel(
                          controller.lastBackupStatus.value,
                        ),
                      ),
                      Obx(() {
                        final remote = controller.remoteMeta.value;
                        if (remote == null) return const SizedBox.shrink();
                        return _InfoRow(
                          label: 'backup_remote_updated'.tr,
                          value: AppFormatters.dateTime(remote.modifiedAt.toLocal()),
                        );
                      }),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: SwitchListTile(
                  title: Text('backup_auto'.tr),
                  subtitle: Text('backup_auto_subtitle'.tr),
                  value: controller.autoBackupEnabled.value,
                  onChanged: controller.isSignedIn
                      ? controller.setAutoBackup
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              if (isRunning) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          _phaseLabel(progress.phase),
                          style: theme.textTheme.titleSmall,
                        ),
                        const SizedBox(height: 12),
                        LinearProgressIndicator(value: progress.percent),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              AppButton(
                label: 'backup_now'.tr,
                onPressed: controller.backupNow,
                isLoading: controller.isLoading.value,
                icon: Icons.cloud_upload_outlined,
              ),
              const SizedBox(height: 12),
              AppButton(
                label: 'backup_restore'.tr,
                onPressed: controller.restore,
                variant: AppButtonVariant.outlined,
                isLoading: controller.isLoading.value,
                icon: Icons.cloud_download_outlined,
              ),
            ],
          ),
        );
      }),
    );
  }

  String _phaseLabel(BackupPhase phase) {
    switch (phase) {
      case BackupPhase.exporting:
        return 'backup_status_exporting'.tr;
      case BackupPhase.uploading:
        return 'backup_status_uploading'.tr;
      case BackupPhase.downloading:
        return 'backup_status_downloading'.tr;
      case BackupPhase.verifying:
        return 'backup_status_verifying'.tr;
      case BackupPhase.restoring:
        return 'backup_status_restoring'.tr;
      case BackupPhase.idle:
        return 'backup_status_idle'.tr;
    }
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
