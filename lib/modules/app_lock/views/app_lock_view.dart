import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../controllers/app_lock_controller.dart';

/// Lock screen shown when app lock is enabled and session is locked.
///
/// PIN and biometric unlock are implemented in Phase 19.
class AppLockView extends GetView<AppLockController> {
  const AppLockView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppScaffold(
      title: 'app_lock_title'.tr,
      automaticallyImplyLeading: false,
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline_rounded,
              size: 72,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'app_lock_subtitle'.tr,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Obx(
              () => AppButton(
                label: 'app_lock_unlock'.tr,
                onPressed: controller.unlock,
                isLoading: controller.isLoading.value,
                icon: Icons.lock_open_rounded,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
