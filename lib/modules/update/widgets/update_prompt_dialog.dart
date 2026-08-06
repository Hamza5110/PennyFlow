import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../data/models/update/release_info.dart';
import '../../../services/update/update_service.dart';

/// Optional / forced update prompt shown after background checks.
abstract final class UpdatePromptDialog {
  static Future<void> showIfNeeded() async {
    if (!Get.isRegistered<UpdateService>()) return;

    final update = Get.find<UpdateService>();
    await update.maybeCheckOnLaunch();

    final release = update.availableUpdate.value;
    if (release == null) return;

    await show(release);
  }

  static Future<void> show(ReleaseInfo release) async {
    final result = await Get.dialog<bool>(
      PopScope(
        canPop: !release.isForced,
        child: AlertDialog(
          title: Text(
            release.isForced
                ? 'update_forced_title'.tr
                : 'update_optional_title'.trParams({
                    'version': release.version,
                  }),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (release.releaseNotes.isNotEmpty)
                  Text(release.releaseNotes)
                else
                  Text('update_optional_message'.trParams({
                    'version': release.version,
                  })),
              ],
            ),
          ),
          actions: [
            if (!release.isForced)
              TextButton(
                onPressed: () {
                  Get.find<UpdateService>().clearPromptedUpdate();
                  Get.back<bool>(result: false);
                },
                child: Text('update_later'.tr),
              ),
            TextButton(
              onPressed: () => Get.back<bool>(result: true),
              child: Text('update_now'.tr),
            ),
          ],
        ),
      ),
      barrierDismissible: !release.isForced,
    );

    if (result == true) {
      await Get.toNamed<void>(AppRoutes.update);
    } else if (!release.isForced) {
      Get.find<UpdateService>().clearPromptedUpdate();
    }
  }
}
