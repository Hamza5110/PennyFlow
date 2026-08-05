import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../services/settings/settings_service.dart';
import '../controllers/income_detail_controller.dart';

class IncomeDetailView extends GetView<IncomeDetailController> {
  const IncomeDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currency = Get.find<SettingsService>().currencyCode.value;

    return AppScaffold(
      title: 'income_detail'.tr,
      body: Obx(() {
        final data = controller.item.value;
        if (data == null) {
          return const Center(child: CircularProgressIndicator());
        }
        final income = data.income;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              AppFormatters.currency(income.amount, currencyCode: currency),
              style: theme.textTheme.headlineMedium?.copyWith(
                color: AppColors.income,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text('${data.sourceLabel} · ${data.accountName}'),
            Text(AppFormatters.dateTime(income.date)),
            if (income.notes != null && income.notes!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('income_notes'.tr, style: theme.textTheme.titleSmall),
              Text(income.notes!),
            ],
            if (income.imagePaths.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('income_images'.tr, style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: income.imagePaths
                    .map(
                      (path) => ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(path),
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
            const SizedBox(height: 24),
            AppButton(label: 'common_edit'.tr, onPressed: controller.edit),
            const SizedBox(height: 8),
            AppButton(
              label: 'income_duplicate'.tr,
              onPressed: controller.duplicate,
              variant: AppButtonVariant.outlined,
            ),
            const SizedBox(height: 8),
            AppButton(
              label: 'common_delete'.tr,
              onPressed: controller.delete,
              variant: AppButtonVariant.outlined,
            ),
          ],
        );
      }),
    );
  }
}
