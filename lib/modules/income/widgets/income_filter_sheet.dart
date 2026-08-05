import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/income_sources.dart';
import '../../../core/utils/app_date_utils.dart';
import '../../../core/widgets/date_filter_section.dart';
import '../../../data/models/income/income_filter.dart';
import '../../../services/payment_account/payment_account_service.dart';

class IncomeFilterSheet extends StatefulWidget {
  const IncomeFilterSheet({
    super.key,
    required this.initial,
    required this.onApply,
  });

  final IncomeFilter initial;
  final ValueChanged<IncomeFilter> onApply;

  static Future<void> show({
    required IncomeFilter initial,
    required ValueChanged<IncomeFilter> onApply,
  }) {
    return Get.bottomSheet<void>(
      IncomeFilterSheet(initial: initial, onApply: onApply),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }

  @override
  State<IncomeFilterSheet> createState() => _IncomeFilterSheetState();
}

class _IncomeFilterSheetState extends State<IncomeFilterSheet> {
  late String? _source;
  late int? _accountId;
  DatePeriod? _period;
  DateRange? _customRange;

  @override
  void initState() {
    super.initState();
    _source = widget.initial.source;
    _accountId = widget.initial.accountId;
    _period = widget.initial.datePeriod;
    _customRange = widget.initial.customRange;
  }

  @override
  Widget build(BuildContext context) {
    final accounts = Get.find<PaymentAccountService>();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: FutureBuilder(
        future: accounts.getActiveAccounts(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const SizedBox(
              height: 120,
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final accountList = snapshot.data!;

          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('income_filters'.tr, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                DropdownButtonFormField<String?>(
                  initialValue: _source,
                  decoration: InputDecoration(labelText: 'income_source'.tr),
                  items: [
                    DropdownMenuItem(value: null, child: Text('income_all_sources'.tr)),
                    for (final key in IncomeSources.predefinedKeys)
                      DropdownMenuItem(
                        value: key,
                        child: Text(IncomeSources.labelKeys[key]!.tr),
                      ),
                  ],
                  onChanged: (v) => setState(() => _source = v),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int?>(
                  initialValue: _accountId,
                  decoration: InputDecoration(labelText: 'income_account'.tr),
                  items: [
                    DropdownMenuItem(value: null, child: Text('income_all_accounts'.tr)),
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
                  label: 'income_date'.tr,
                  onChanged: (selection) {
                    setState(() {
                      _period = selection.period;
                      _customRange = selection.customRange;
                    });
                  },
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () {
                    widget.onApply(
                      widget.initial.copyWith(
                        source: _source,
                        accountId: _accountId,
                        datePeriod: _period,
                        customRange: _customRange,
                        clearSource: _source == null,
                        clearAccount: _accountId == null,
                        clearDate: _period == null && _customRange == null,
                      ),
                    );
                    Get.back<void>();
                  },
                  child: Text('income_apply_filters'.tr),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
