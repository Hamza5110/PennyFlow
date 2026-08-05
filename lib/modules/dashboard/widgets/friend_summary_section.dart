import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/dashboard/dashboard_summary.dart';

class FriendSummarySection extends StatelessWidget {
  const FriendSummarySection({
    super.key,
    required this.summary,
    required this.currencyCode,
  });

  final DashboardSummary summary;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    String money(double v) =>
        AppFormatters.currency(v, currencyCode: currencyCode);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'dashboard_friend_tracker'.tr,
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 12),
            _FriendRow(
              label: 'dashboard_money_lent'.tr,
              value: money(summary.moneyLent),
              color: AppColors.transfer,
            ),
            _FriendRow(
              label: 'dashboard_money_borrowed'.tr,
              value: money(summary.moneyBorrowed),
              color: AppColors.pending,
            ),
            _FriendRow(
              label: 'dashboard_pending_receive'.tr,
              value: money(summary.pendingReceive),
              color: AppColors.income,
            ),
            _FriendRow(
              label: 'dashboard_pending_pay'.tr,
              value: money(summary.pendingPay),
              color: AppColors.expense,
            ),
          ],
        ),
      ),
    );
  }
}

class _FriendRow extends StatelessWidget {
  const _FriendRow({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
