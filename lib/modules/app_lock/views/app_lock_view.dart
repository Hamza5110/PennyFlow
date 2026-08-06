import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/validation_constants.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/pin_dots.dart';
import '../../../core/widgets/pin_pad.dart';
import '../controllers/app_lock_controller.dart';

class AppLockView extends GetView<AppLockController> {
  const AppLockView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppScaffold(
      title: 'app_lock_title'.tr,
      automaticallyImplyLeading: false,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Spacer(),
            Icon(
              Icons.lock_outline_rounded,
              size: 64,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'app_lock_subtitle'.tr,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Obx(
              () => PinDots(
                length: controller.pinBuffer.value.length,
                maxLength: ValidationConstants.minPinLength,
                hasError: controller.hasError.value,
              ),
            ),
            const Spacer(),
            Obx(
              () => PinPad(
                key: const ValueKey('app_lock_pad'),
                onDigit: controller.onDigit,
                onBackspace: controller.onBackspace,
                showBiometric: controller.showBiometric.value,
                onBiometric: controller.unlockWithBiometric,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
