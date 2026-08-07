import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/settings_constants.dart';
import '../controllers/settings_controller.dart';
import '../widgets/settings_picker_view.dart';

class CurrencyPickerView extends GetView<SettingsController> {
  const CurrencyPickerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => SettingsPickerView<String>(
        title: 'settings_currency'.tr,
        subtitle: 'settings_currency_subtitle'.tr,
        selectedValue: controller.currencyCode.value,
        onSelected: (code) {
          controller.updateCurrency(code);
          Get.back<void>();
        },
        options: [
          for (final option in SettingsConstants.currencyOptions)
            SettingsPickerOption(
              value: option.code,
              title: option.labelKey.tr,
              subtitle: option.code,
              leading: _CurrencyBadge(symbol: option.symbol),
            ),
        ],
      ),
    );
  }
}

class _CurrencyBadge extends StatelessWidget {
  const _CurrencyBadge({required this.symbol});

  final String symbol;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        symbol,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.secondary,
            ),
      ),
    );
  }
}
