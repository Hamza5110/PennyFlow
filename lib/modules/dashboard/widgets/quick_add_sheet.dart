import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/utils/category_icons.dart';
import '../../../core/widgets/app_bottom_sheet.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../data/models/category.dart';
import '../../../data/models/expense/expense_input.dart';
import '../../../data/models/payment_account.dart';
import '../../../services/category/category_service.dart';
import '../../../services/expense/expense_service.dart';
import '../../../services/payment_account/payment_account_service.dart';
import '../../expenses/expense_routes.dart';

/// Fast expense entry for Simple Mode — amount, a category chip, and an
/// account that defaults sensibly, saved directly through [ExpenseService].
///
/// Full Mode keeps using the full [ExpenseFormView] instead of this sheet.
class QuickAddSheet extends StatefulWidget {
  const QuickAddSheet({super.key});

  /// Shows the sheet and returns true if an expense was saved.
  static Future<bool> show() async {
    final result = await Get.bottomSheet<bool>(
      const QuickAddSheet(),
      isScrollControlled: true,
      backgroundColor: AppBottomSheet.backgroundColorFromTheme,
      shape: AppBottomSheet.shape,
    );
    return result ?? false;
  }

  @override
  State<QuickAddSheet> createState() => _QuickAddSheetState();
}

class _QuickAddSheetState extends State<QuickAddSheet> {
  final _categoryService = Get.find<CategoryService>();
  final _accountService = Get.find<PaymentAccountService>();
  final _expenseService = Get.find<ExpenseService>();

  final _amountController = TextEditingController();

  List<Category> _categories = [];
  List<PaymentAccount> _accounts = [];
  int? _selectedCategoryId;
  int? _selectedAccountId;
  bool _isLoadingOptions = true;
  bool _isSaving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadOptions();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _loadOptions() async {
    final categories = await _categoryService.getCategories();
    final accounts = await _accountService.getActiveAccounts();
    if (!mounted) return;
    setState(() {
      _categories = categories;
      _accounts = accounts;
      _selectedCategoryId = categories.isNotEmpty ? categories.first.id : null;
      _selectedAccountId = accounts.isNotEmpty ? accounts.first.id : null;
      _isLoadingOptions = false;
    });
  }

  double? get _parsedAmount => double.tryParse(_amountController.text.trim());

  Future<void> _save() async {
    final amount = _parsedAmount;
    if (amount == null || amount <= 0) {
      setState(() => _error = 'validation_amount_invalid'.tr);
      return;
    }
    if (_selectedCategoryId == null || _selectedAccountId == null) {
      setState(() => _error = 'quick_add_setup_required'.tr);
      return;
    }

    setState(() {
      _isSaving = true;
      _error = null;
    });

    final result = await _expenseService.create(
      ExpenseInput(
        amount: amount,
        categoryId: _selectedCategoryId!,
        accountId: _selectedAccountId!,
        date: DateTime.now(),
      ),
    );

    if (!mounted) return;

    if (result.success) {
      Get.back<bool>(result: true);
      return;
    }

    setState(() {
      _isSaving = false;
      _error = result.userMessage ?? 'common_something_went_wrong'.tr;
    });
  }

  void _openFullForm() {
    Get.back<bool>(result: false);
    Get.toNamed<dynamic>(
      AppRoutes.expenseForm,
      arguments: ExpenseFormArgs(prefillAmount: _parsedAmount),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 150),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
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
              const SizedBox(height: 20),
              Text('dashboard_quick_add'.tr, style: theme.textTheme.titleLarge),
              const SizedBox(height: 16),
              AppTextField(
                controller: _amountController,
                label: 'expense_amount'.tr,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                prefixIcon: Icons.payments_outlined,
                autofocus: true,
                onChanged: (_) {
                  if (_error != null) setState(() => _error = null);
                },
                onSubmitted: (_) => _save(),
              ),
              const SizedBox(height: 16),
              if (_isLoadingOptions)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                )
              else ...[
                if (_categories.isEmpty)
                  Text(
                    'quick_add_no_categories'.tr,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  )
                else
                  SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        final selected = category.id == _selectedCategoryId;
                        return ChoiceChip(
                          label: Text(category.name),
                          avatar: Icon(
                            CategoryIcons.fromKey(category.iconKey),
                            size: 16,
                            color: selected
                                ? theme.colorScheme.onPrimary
                                : CategoryIcons.parseColor(category.colorHex),
                          ),
                          selected: selected,
                          onSelected: (_) =>
                              setState(() => _selectedCategoryId = category.id),
                        );
                      },
                    ),
                  ),
                if (_accounts.length > 1) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        'expense_account'.tr,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color:
                              theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            isExpanded: true,
                            value: _selectedAccountId,
                            items: [
                              for (final account in _accounts)
                                DropdownMenuItem(
                                  value: account.id,
                                  child: Text(
                                    account.name,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                            ],
                            onChanged: (value) =>
                                setState(() => _selectedAccountId = value),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
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
                label: 'common_save'.tr,
                onPressed: _isLoadingOptions ? null : _save,
                isLoading: _isSaving,
              ),
              const SizedBox(height: 8),
              AppButton(
                label: 'quick_add_more_details'.tr,
                onPressed: _isSaving ? null : _openFullForm,
                variant: AppButtonVariant.text,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
