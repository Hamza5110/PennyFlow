import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/base/base_controller.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/error_handler.dart';
import '../../../core/utils/budget_period_utils.dart';
import '../../../data/models/budget_envelope.dart';
import '../../../data/models/budget_envelope/budget_envelope_input.dart';
import '../../../data/models/enums/app_enums.dart';
import '../../../data/models/payment_account.dart';
import '../../../services/budget_envelope/budget_envelope_service.dart';
import '../../../services/payment_account/payment_account_service.dart';
import '../budget_routes.dart';

class EnvelopeFundingRow {
  EnvelopeFundingRow({this.accountId, String amount = ''})
      : amountController = TextEditingController(text: amount);

  int? accountId;
  final TextEditingController amountController;

  void dispose() => amountController.dispose();
}

class EnvelopeFormController extends BaseController {
  EnvelopeFormController(this._envelopes, this._accounts);

  final BudgetEnvelopeService _envelopes;
  final PaymentAccountService _accounts;

  final totalController = TextEditingController();
  final thresholdController = TextEditingController(
    text: (AppConstants.defaultBudgetWarningThreshold * 100).toStringAsFixed(0),
  );

  final RxList<PaymentAccount> accounts = <PaymentAccount>[].obs;
  final RxList<EnvelopeFundingRow> fundingRows = <EnvelopeFundingRow>[].obs;

  final Rx<BudgetPeriodType> periodType = BudgetPeriodType.days7.obs;
  final Rx<DateTime> periodStart = DateTime.now().obs;
  final Rx<DateTime> periodEnd = DateTime.now().obs;
  final RxBool autoRepeat = true.obs;
  final RxBool recordFundingAsIncome = true.obs;

  final RxDouble fundingAllocated = 0.0.obs;
  final RxDouble totalAmount = 0.0.obs;

  int? _envelopeId;
  bool get isEditing => _envelopeId != null;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is EnvelopeFormArgs) _envelopeId = args.envelopeId;
    _syncPeriodEndFromType();
    totalController.addListener(_recalcTotals);
    _bootstrap();
  }

  @override
  void onClose() {
    totalController
      ..removeListener(_recalcTotals)
      ..dispose();
    thresholdController.dispose();
    for (final row in fundingRows) {
      row.dispose();
    }
    super.onClose();
  }

  Future<void> _bootstrap() async {
    await runGuarded(() async {
      accounts.assignAll(await _accounts.getActiveAccounts());

      if (_envelopeId != null) {
        final envelope = await _envelopes.getById(_envelopeId!);
        if (envelope == null) {
          ErrorHandler.showError('envelope_not_found'.tr);
          Get.back<void>();
          return;
        }
        _populate(envelope);
        recordFundingAsIncome.value = false;
      } else {
        addFundingRow();
      }
      _recalcTotals();
    }, showErrorSnackbar: false);
  }

  void _populate(BudgetEnvelope envelope) {
    totalController.text = envelope.totalAmount.toStringAsFixed(2);
    thresholdController.text =
        (envelope.warningThreshold * 100).toStringAsFixed(0);
    periodType.value = BudgetPeriodUtils.typeOfEnvelope(envelope);
    periodStart.value = BudgetPeriodUtils.startOfDay(envelope.periodStart);
    periodEnd.value = BudgetPeriodUtils.startOfDay(envelope.periodEnd);
    autoRepeat.value = envelope.autoRepeat;

    for (final row in fundingRows) {
      row.dispose();
    }
    fundingRows.assignAll(
      envelope.fundingSplits.map(
        (s) => EnvelopeFundingRow(
          accountId: s.accountId,
          amount: s.amount.toStringAsFixed(2),
        ),
      ),
    );
    if (fundingRows.isEmpty) {
      addFundingRow();
    } else {
      for (final row in fundingRows) {
        row.amountController.addListener(_recalcTotals);
      }
    }
  }

  void addFundingRow() {
    final row = EnvelopeFundingRow(
      accountId: accounts.isEmpty ? null : accounts.first.id,
    );
    row.amountController.addListener(_recalcTotals);
    fundingRows.add(row);
  }

  void removeFundingRow(int index) {
    if (fundingRows.length <= 1) return;
    final row = fundingRows.removeAt(index);
    row.amountController.removeListener(_recalcTotals);
    row.dispose();
    _recalcTotals();
  }

  void setAccount(int index, int? accountId) {
    fundingRows[index].accountId = accountId;
    fundingRows.refresh();
  }

  void setPeriodType(BudgetPeriodType type) {
    periodType.value = type;
    _syncPeriodEndFromType();
  }

  Future<void> pickStartDate() async {
    final picked = await showDatePicker(
      context: Get.context!,
      initialDate: periodStart.value,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    periodStart.value = BudgetPeriodUtils.startOfDay(picked);
    if (periodType.value != BudgetPeriodType.custom ||
        periodEnd.value.isBefore(periodStart.value)) {
      _syncPeriodEndFromType();
    }
  }

  Future<void> pickEndDate() async {
    final picked = await showDatePicker(
      context: Get.context!,
      initialDate: periodEnd.value.isBefore(periodStart.value)
          ? periodStart.value
          : periodEnd.value,
      firstDate: periodStart.value,
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    periodEnd.value = BudgetPeriodUtils.startOfDay(picked);
  }

  void _syncPeriodEndFromType() {
    periodEnd.value = BudgetPeriodUtils.startOfDay(
      BudgetPeriodUtils.defaultPeriodEnd(
        type: periodType.value,
        periodStart: periodStart.value,
        customEnd: periodEnd.value,
      ),
    );
  }

  void _recalcTotals() {
    totalAmount.value = double.tryParse(totalController.text.trim()) ?? 0;
    fundingAllocated.value = fundingRows.fold<double>(
      0,
      (sum, row) =>
          sum + (double.tryParse(row.amountController.text.trim()) ?? 0),
    );
  }

  BudgetEnvelopeInput _buildInput() {
    final type = periodType.value;
    final start = BudgetPeriodUtils.startOfDay(periodStart.value);
    final end = BudgetPeriodUtils.defaultPeriodEnd(
      type: type,
      periodStart: start,
      customEnd: periodEnd.value,
    );

    return BudgetEnvelopeInput(
      totalAmount: double.parse(totalController.text.trim()),
      periodType: type,
      periodStart: start,
      periodEnd: end,
      autoRepeat: autoRepeat.value,
      warningThreshold: double.parse(thresholdController.text.trim()) / 100,
      recordFundingAsIncome: recordFundingAsIncome.value,
      fundingSplits: [
        for (final row in fundingRows)
          EnvelopeFundingSplitInput(
            accountId: row.accountId!,
            amount: double.parse(row.amountController.text.trim()),
          ),
      ],
    );
  }

  Future<void> save() async {
    await runGuarded(() async {
      for (final row in fundingRows) {
        if (row.accountId == null) {
          ErrorHandler.showError('envelope_account_required'.tr);
          return;
        }
      }

      final input = _buildInput();
      final result = isEditing
          ? await _envelopes.update(_envelopeId!, input)
          : await _envelopes.create(input);
      if (result.success) {
        ErrorHandler.popWithSuccess(
          isEditing ? 'envelope_updated'.tr : 'envelope_created'.tr,
        );
        return;
      } else if (result.userMessage != null) {
        ErrorHandler.showError(result.userMessage!);
      }
    });
  }
}
