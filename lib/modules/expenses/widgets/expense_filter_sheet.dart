import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/app_date_utils.dart';
import '../../../core/widgets/date_filter_section.dart';
import '../../../data/models/category.dart';
import '../../../data/models/expense/expense_filter.dart';
import '../../../data/models/payment_account.dart';
import '../../../services/category/category_service.dart';
import '../../../services/payment_account/payment_account_service.dart';

class ExpenseFilterSheet extends StatefulWidget {
  const ExpenseFilterSheet({
    super.key,
    required this.initial,
    required this.onApply,
  });

  final ExpenseFilter initial;
  final ValueChanged<ExpenseFilter> onApply;

  static Future<void> show({
    required ExpenseFilter initial,
    required ValueChanged<ExpenseFilter> onApply,
  }) {
    return Get.bottomSheet<void>(
      ExpenseFilterSheet(initial: initial, onApply: onApply),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }

  @override
  State<ExpenseFilterSheet> createState() => _ExpenseFilterSheetState();
}

class _ExpenseFilterSheetState extends State<ExpenseFilterSheet> {
  late int? _categoryId;
  late int? _accountId;
  DatePeriod? _period;
  DateRange? _customRange;
  final _tagController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _categoryId = widget.initial.categoryId;
    _accountId = widget.initial.accountId;
    _period = widget.initial.datePeriod;
    _customRange = widget.initial.customRange;
    _tagController.text = widget.initial.tag ?? '';
  }

  @override
  void dispose() {
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = Get.find<CategoryService>();
    final accounts = Get.find<PaymentAccountService>();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: FutureBuilder(
        future: Future.wait([
          categories.getCategories(),
          accounts.getActiveAccounts(),
        ]),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const SizedBox(
              height: 120,
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final categoryList = snapshot.data![0] as List<Category>;
          final accountList = snapshot.data![1] as List<PaymentAccount>;

          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'expense_filters'.tr,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int?>(
                  initialValue: _categoryId,
                  decoration: InputDecoration(labelText: 'expense_category'.tr),
                  items: [
                    DropdownMenuItem(
                      value: null,
                      child: Text('expense_all_categories'.tr),
                    ),
                    ...categoryList.map(
                      (c) => DropdownMenuItem(value: c.id, child: Text(c.name)),
                    ),
                  ],
                  onChanged: (v) => setState(() => _categoryId = v),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int?>(
                  initialValue: _accountId,
                  decoration: InputDecoration(labelText: 'expense_account'.tr),
                  items: [
                    DropdownMenuItem(
                      value: null,
                      child: Text('expense_all_accounts'.tr),
                    ),
                    ...accountList.map(
                      (a) => DropdownMenuItem(value: a.id, child: Text(a.name)),
                    ),
                  ],
                  onChanged: (v) => setState(() => _accountId = v),
                ),
                const SizedBox(height: 12),
                DateFilterSection(
                  initialPeriod: _period,
                  initialCustomRange: _customRange,
                  label: 'expense_date'.tr,
                  onChanged: (selection) {
                    setState(() {
                      _period = selection.period;
                      _customRange = selection.customRange;
                    });
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _tagController,
                  decoration: InputDecoration(labelText: 'expense_tags'.tr),
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () {
                    widget.onApply(
                      widget.initial.copyWith(
                        categoryId: _categoryId,
                        accountId: _accountId,
                        datePeriod: _period,
                        customRange: _customRange,
                        tag: _tagController.text.trim().isEmpty
                            ? null
                            : _tagController.text.trim(),
                        clearCategory: _categoryId == null,
                        clearAccount: _accountId == null,
                        clearDate: _period == null && _customRange == null,
                        clearTag: _tagController.text.trim().isEmpty,
                      ),
                    );
                    Get.back<void>();
                  },
                  child: Text('expense_apply_filters'.tr),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
