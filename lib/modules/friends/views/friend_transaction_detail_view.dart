import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/constants/friend_constants.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../services/settings/settings_service.dart';
import '../../../core/widgets/receipt_image_picker_section.dart';
import '../controllers/friend_transaction_detail_controller.dart';

class FriendTransactionDetailView
    extends GetView<FriendTransactionDetailController> {
  const FriendTransactionDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currency = Get.find<SettingsService>().currencyCode.value;

    return AppScaffold(
      title: 'friends_transaction_detail'.tr,
      body: Obx(() {
        final data = controller.item.value;
        if (data == null) {
          return const Center(child: CircularProgressIndicator());
        }
        final txn = data.transaction;
        final isGiven = txn.type == FriendTransactionTypes.given;
        final color = isGiven ? AppColors.income : AppColors.expense;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              AppFormatters.currency(txn.amount, currencyCode: currency),
              style: theme.textTheme.headlineMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(data.friendName),
            Text(
              isGiven
                  ? 'friends_money_given'.tr
                  : 'friends_money_received'.tr,
            ),
            Text(AppFormatters.date(txn.date)),
            if (txn.dueDate != null)
              Text('${'friends_due_date'.tr}: ${AppFormatters.date(txn.dueDate!)}'),
            Text(_statusLabel(txn.status)),
            if (data.remainingBalance > 0) ...[
              const SizedBox(height: 8),
              Text(
                'friends_remaining'.trParams({
                  'amount': AppFormatters.currency(
                    data.remainingBalance,
                    currencyCode: currency,
                  ),
                }),
              ),
            ],
            if (txn.notes != null && txn.notes!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('friends_notes'.tr, style: theme.textTheme.titleSmall),
              Text(txn.notes!),
            ],
            if (txn.imagePaths.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('friends_receipts'.tr, style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              ReceiptThumbnailGrid(imagePaths: txn.imagePaths),
            ],
            const SizedBox(height: 24),
            Text(
              'friends_repayments'.tr,
              style: theme.textTheme.titleSmall,
            ),
            if (controller.repayments.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text('friends_no_repayments'.tr),
              )
            else
              ...controller.repayments.map(
                (r) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    AppFormatters.currency(r.amount, currencyCode: currency),
                  ),
                  subtitle: Text(
                    '${AppFormatters.date(r.date)}${r.note != null ? ' · ${r.note}' : ''}',
                  ),
                ),
              ),
            const SizedBox(height: 16),
            if (data.remainingBalance > 0)
              AppButton(
                label: 'friends_add_repayment'.tr,
                onPressed: controller.addRepayment,
              ),
            const SizedBox(height: 8),
            AppButton(label: 'common_edit'.tr, onPressed: controller.edit),
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

  String _statusLabel(String status) {
    switch (status) {
      case FriendTransactionStatus.completed:
        return 'friends_status_completed'.tr;
      case FriendTransactionStatus.partiallyPaid:
        return 'friends_status_partial'.tr;
      default:
        return 'friends_status_pending'.tr;
    }
  }
}
