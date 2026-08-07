import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/settings_constants.dart';
import '../controllers/settings_controller.dart';
import '../widgets/settings_picker_view.dart';

class LanguagePickerView extends GetView<SettingsController> {
  const LanguagePickerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => SettingsPickerView<String>(
        title: 'settings_language'.tr,
        subtitle: 'settings_language_subtitle'.tr,
        selectedValue: controller.localeCode.value,
        onSelected: (code) {
          controller.setLocale(code);
          Get.back<void>();
        },
        options: [
          for (final option in SettingsConstants.supportedLocales)
            SettingsPickerOption(
              value: option.code,
              title: option.labelKey.tr,
              leading: _LanguageBadge(code: option.code),
            ),
        ],
      ),
    );
  }
}

class _LanguageBadge extends StatelessWidget {
  const _LanguageBadge({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final label = code == 'ur' ? 'ا' : 'En';

    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.primary,
            ),
      ),
    );
  }
}
