import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/settings_constants.dart';
import '../controllers/settings_controller.dart';
import '../widgets/settings_picker_view.dart';

class LockTimeoutPickerView extends GetView<SettingsController> {
  const LockTimeoutPickerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => SettingsPickerView<int>(
        title: 'security_lock_timeout'.tr,
        subtitle: 'security_lock_timeout_subtitle'.tr,
        selectedValue: controller.lockTimeoutMinutes.value,
        onSelected: (minutes) {
          controller.setLockTimeout(minutes);
          Get.back<void>();
        },
        options: [
          for (final option in SettingsConstants.lockTimeoutOptions)
            SettingsPickerOption(
              value: option.minutes,
              title: option.labelKey.tr,
              leading: Icon(
                _iconFor(option.minutes),
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
        ],
      ),
    );
  }

  IconData _iconFor(int minutes) {
    return switch (minutes) {
      0 => Icons.lock_clock_rounded,
      1 => Icons.timer_outlined,
      5 => Icons.timer_rounded,
      15 => Icons.hourglass_top_rounded,
      30 => Icons.hourglass_bottom_rounded,
      _ => Icons.timer_rounded,
    };
  }
}
