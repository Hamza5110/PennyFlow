import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_loading_indicator.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../data/models/update/update_progress.dart';
import '../controllers/update_controller.dart';

class UpdateView extends GetView<UpdateController> {
  const UpdateView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppScaffold(
      title: 'update_title'.tr,
      actions: [
        IconButton(
          icon: const Icon(Icons.history_rounded),
          tooltip: 'update_history_title'.tr,
          onPressed: () => Get.toNamed<void>(AppRoutes.updateHistory),
        ),
      ],
      body: Obx(() {
        final release = controller.release.value;
        final progress = controller.progress.value;
        final isChecking = progress?.phase == UpdateDownloadPhase.checking;

        if (isChecking && release == null) {
          return AppLoadingIndicator(message: 'update_phase_checking'.tr);
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'update_current_version'.tr,
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'update_version_value'.trParams({
                        'version': controller.currentVersion.value,
                        'build': controller.currentBuild.value,
                      }),
                      style: theme.textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (release != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'update_available_title'.trParams({
                                'version': release.version,
                              }),
                              style: theme.textTheme.titleSmall,
                            ),
                          ),
                          if (release.isForced)
                            Chip(
                              label: Text('update_forced_badge'.tr),
                              visualDensity: VisualDensity.compact,
                            ),
                        ],
                      ),
                      if (release.apkSizeBytes > 0) ...[
                        const SizedBox(height: 8),
                        Text(
                          'update_apk_size'.trParams({
                            'size': controller.formatSize(release.apkSizeBytes),
                          }),
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                      if (release.releaseNotes.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text(
                          'update_release_notes'.tr,
                          style: theme.textTheme.titleSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          release.releaseNotes,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (progress != null &&
                progress.phase != UpdateDownloadPhase.idle &&
                progress.phase != UpdateDownloadPhase.checking) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        controller.phaseLabel(progress.phase),
                        style: theme.textTheme.titleSmall,
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(value: progress.percent),
                      const SizedBox(height: 8),
                      Text(
                        'update_progress_bytes'.trParams({
                          'received': controller.formatSize(progress.receivedBytes),
                          'total': controller.formatSize(progress.totalBytes),
                        }),
                        style: theme.textTheme.bodySmall,
                      ),
                      if (progress.phase == UpdateDownloadPhase.downloading) ...[
                        const SizedBox(height: 4),
                        Text(
                          'update_progress_speed'.trParams({
                            'speed': controller.formatSpeed(
                              progress.speedBytesPerSecond,
                            ),
                          }),
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            AppButton(
              label: release == null
                  ? 'update_check_now'.tr
                  : 'update_download'.tr,
              onPressed: release == null
                  ? controller.checkForUpdate
                  : controller.isDownloading || controller.isReadyToInstall
                      ? null
                      : controller.download,
              isLoading: controller.isLoading.value,
              icon: release == null
                  ? Icons.system_update_outlined
                  : Icons.download_outlined,
            ),
            if (controller.isDownloading) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: progress?.phase == UpdateDownloadPhase.paused
                          ? 'update_resume'.tr
                          : 'update_pause'.tr,
                      onPressed: progress?.phase == UpdateDownloadPhase.paused
                          ? controller.resumeDownload
                          : controller.pauseDownload,
                      variant: AppButtonVariant.outlined,
                      icon: progress?.phase == UpdateDownloadPhase.paused
                          ? Icons.play_arrow_rounded
                          : Icons.pause_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      label: 'update_retry'.tr,
                      onPressed: controller.retryDownload,
                      variant: AppButtonVariant.outlined,
                      icon: Icons.refresh_rounded,
                    ),
                  ),
                ],
              ),
            ],
            if (controller.isReadyToInstall) ...[
              const SizedBox(height: 12),
              AppButton(
                label: 'update_install'.tr,
                onPressed: controller.install,
                icon: Icons.install_mobile_rounded,
              ),
            ],
          ],
        );
      }),
    );
  }
}
