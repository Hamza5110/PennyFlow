import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/receipt_image_picker_section.dart';
import '../../../services/settings/settings_service.dart';
import '../controllers/expense_detail_controller.dart';

class ExpenseDetailView extends GetView<ExpenseDetailController> {
  const ExpenseDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currency = Get.find<SettingsService>().currencyCode.value;

    return AppScaffold(
      title: 'expense_detail'.tr,
      body: Obx(() {
        final data = controller.item.value;
        if (data == null) {
          return const Center(child: CircularProgressIndicator());
        }
        final expense = data.expense;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              AppFormatters.currency(expense.amount, currencyCode: currency),
              style: theme.textTheme.headlineMedium?.copyWith(
                color: AppColors.expense,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text('${data.categoryName} · ${data.accountName}'),
            Text(AppFormatters.dateTime(expense.date)),
            if (expense.notes != null && expense.notes!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('expense_notes'.tr, style: theme.textTheme.titleSmall),
              Text(expense.notes!),
            ],
            if (expense.location != null && expense.location!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('expense_location'.tr, style: theme.textTheme.titleSmall),
              Text(expense.location!),
            ],
            if (expense.tags.isNotEmpty) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: expense.tags.map((t) => Chip(label: Text(t))).toList(),
              ),
            ],
            if (expense.receiptImagePaths.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('expense_receipts'.tr, style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              ReceiptThumbnailGrid(imagePaths: expense.receiptImagePaths),
            ],
            const SizedBox(height: 24),
            AppButton(label: 'common_edit'.tr, onPressed: controller.edit),
            const SizedBox(height: 8),
            AppButton(
              label: 'expense_duplicate'.tr,
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
