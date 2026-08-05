import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../data/models/dashboard/mock_quick_add_option.dart';

typedef QuickAddSubmit = Future<void> Function({
  required double amount,
  required String categoryId,
  required String accountId,
});

/// Mock Quick Add sheet — persists to mock repository only (Phase 3).
///
/// Full expense module replaces this in Phase 4.
class QuickAddSheet extends StatefulWidget {
  const QuickAddSheet({
    super.key,
    required this.categories,
    required this.accounts,
    required this.onSubmit,
    required this.isLoading,
  });

  final List<MockQuickAddCategory> categories;
  final List<MockQuickAddAccount> accounts;
  final QuickAddSubmit onSubmit;
  final bool isLoading;

  static Future<void> show({
    required List<MockQuickAddCategory> categories,
    required List<MockQuickAddAccount> accounts,
    required QuickAddSubmit onSubmit,
    required RxBool isLoading,
  }) async {
    await Get.bottomSheet<void>(
      Obx(
        () => QuickAddSheet(
          categories: categories,
          accounts: accounts,
          onSubmit: onSubmit,
          isLoading: isLoading.value,
        ),
      ),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }

  @override
  State<QuickAddSheet> createState() => _QuickAddSheetState();
}

class _QuickAddSheetState extends State<QuickAddSheet> {
  final _amountController = TextEditingController();
  String? _categoryId;
  String? _accountId;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.categories.isNotEmpty) {
      _categoryId = widget.categories.first.id;
    }
    if (widget.accounts.isNotEmpty) {
      _accountId = widget.accounts.first.id;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final amountError = AppValidators.amount(_amountController.text);
    if (amountError != null) {
      setState(() => _error = amountError);
      return;
    }
    if (_categoryId == null || _accountId == null) {
      setState(() => _error = 'dashboard_quick_add_missing'.tr);
      return;
    }

    setState(() => _error = null);
    final amount = double.parse(_amountController.text.trim());
    await widget.onSubmit(
      amount: amount,
      categoryId: _categoryId!,
      accountId: _accountId!,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'dashboard_quick_add_title'.tr,
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'dashboard_quick_add_subtitle'.tr,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
            ),
          ),
          const SizedBox(height: 20),
          AppTextField(
            controller: _amountController,
            label: 'dashboard_quick_add_amount'.tr,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ],
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 16),
          Text(
            'dashboard_quick_add_category'.tr,
            style: theme.textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.categories.map((category) {
              return ChoiceChip(
                label: Text(category.name),
                selected: _categoryId == category.id,
                onSelected: (_) => setState(() => _categoryId = category.id),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Text(
            'dashboard_quick_add_account'.tr,
            style: theme.textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.accounts.map((account) {
              return ChoiceChip(
                label: Text(account.name),
                selected: _accountId == account.id,
                onSelected: (_) => setState(() => _accountId = account.id),
              );
            }).toList(),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ],
          const SizedBox(height: 20),
          AppButton(
            label: 'dashboard_quick_add_save'.tr,
            onPressed: _submit,
            isLoading: widget.isLoading,
          ),
        ],
      ),
    );
  }
}
