import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/dashboard/dashboard_transaction.dart';

class RecentTransactionsSection extends StatelessWidget {
  const RecentTransactionsSection({
    super.key,
    required this.transactions,
    required this.currencyCode,
    this.onTransactionTap,
  });

  final List<DashboardTransaction> transactions;
  final String currencyCode;
  final ValueChanged<DashboardTransaction>? onTransactionTap;

  Color _parseColor(String hex) {
    final cleaned = hex.replaceFirst('#', '');
    return Color(int.parse('FF$cleaned', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'dashboard_recent_transactions'.tr,
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            if (transactions.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'dashboard_no_transactions'.tr,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: transactions.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = transactions[index];
                  final isExpense = item.isExpense;
                  final amountColor =
                      isExpense ? AppColors.expense : AppColors.income;
                  final prefix = isExpense ? '−' : '+';

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor:
                          _parseColor(item.colorHex).withValues(alpha: 0.15),
                      child: Icon(
                        isExpense
                            ? Icons.arrow_upward_rounded
                            : Icons.arrow_downward_rounded,
                        color: _parseColor(item.colorHex),
                        size: 20,
                      ),
                    ),
                    title: Text(item.title),
                    subtitle: Text(
                      '${item.subtitle} · ${item.accountName}',
                    ),
                    trailing: Text(
                      '$prefix${AppFormatters.currency(item.amount, currencyCode: currencyCode)}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: amountColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    onTap: onTransactionTap == null
                        ? null
                        : () => onTransactionTap!(item),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
