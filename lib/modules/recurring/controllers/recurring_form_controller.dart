import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/base/base_controller.dart';
import '../../../core/constants/income_sources.dart';
import '../../../core/constants/recurring_constants.dart';
import '../../../core/errors/error_handler.dart';
import '../../../data/models/category.dart';
import '../../../data/models/payment_account.dart';
import '../../../data/models/recurring/recurring_template_input.dart';
import '../../../data/models/recurring_template.dart';
import '../../../services/category/category_service.dart';
import '../../../services/payment_account/payment_account_service.dart';
import '../../../services/recurring/recurring_service.dart';
import '../recurring_routes.dart';

class RecurringFormController extends BaseController {
  RecurringFormController(
    this._recurring,
    this._categories,
    this._accounts,
  );

  final RecurringService _recurring;
  final CategoryService _categories;
  final PaymentAccountService _accounts;

  final amountController = TextEditingController();
  final notesController = TextEditingController();
  final customSourceController = TextEditingController();

  final RxString transactionType = RecurringTransactionTypes.expense.obs;
  final RxString frequency = RecurringFrequencies.monthly.obs;
  final RxList<Category> categories = <Category>[].obs;
  final RxList<PaymentAccount> accounts = <PaymentAccount>[].obs;
  final RxnInt selectedCategoryId = RxnInt();
  final RxnInt selectedAccountId = RxnInt();
  final RxString selectedSourceKey = IncomeSources.salary.obs;
  final RxBool useCustomSource = false.obs;
  final RxBool isActive = true.obs;
  final Rx<DateTime> startDate = DateTime.now().obs;

  int? _templateId;
  bool get isEditing => _templateId != null;

  List<({String key, String label})> get sourceOptions => [
        for (final key in IncomeSources.predefinedKeys)
          (key: key, label: IncomeSources.labelKeys[key]!.tr),
        (key: IncomeSources.custom, label: 'income_source_custom'.tr),
      ];

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is RecurringFormArgs) {
      _templateId = args.templateId;
      if (args.transactionType != null) {
        transactionType.value = args.transactionType!;
      }
    }
    _bootstrap();
  }

  @override
  void onClose() {
    amountController.dispose();
    notesController.dispose();
    customSourceController.dispose();
    super.onClose();
  }

  Future<void> _bootstrap() async {
    await runGuarded(() async {
      categories.assignAll(await _categories.getCategories());
      accounts.assignAll(await _accounts.getActiveAccounts());

      if (_templateId != null) {
        final template = await _recurring.getById(_templateId!);
        if (template == null) {
          ErrorHandler.showError('recurring_not_found'.tr);
          Get.back<void>();
          return;
        }
        _populate(template);
      } else {
        if (categories.isNotEmpty) {
          selectedCategoryId.value = categories.first.id;
        }
        if (accounts.isNotEmpty) {
          selectedAccountId.value = accounts.first.id;
        }
      }
    }, showErrorSnackbar: false);
  }

  void _populate(RecurringTemplate template) {
    amountController.text = template.amount.toStringAsFixed(2);
    notesController.text = template.notes ?? '';
    transactionType.value = template.transactionType;
    frequency.value = template.frequency;
    selectedCategoryId.value = template.categoryId;
    selectedAccountId.value = template.accountId;
    isActive.value = template.isActive;
    startDate.value = template.startDate;

    if (template.transactionType == RecurringTransactionTypes.income) {
      final source = template.source ?? IncomeSources.salary;
      if (IncomeSources.isPredefinedKey(source)) {
        selectedSourceKey.value = source;
        useCustomSource.value = false;
      } else {
        useCustomSource.value = true;
        selectedSourceKey.value = IncomeSources.custom;
        customSourceController.text = source;
      }
    }
  }

  void onSourceChanged(String? value) {
    if (value == null) return;
    if (value == IncomeSources.custom) {
      useCustomSource.value = true;
      selectedSourceKey.value = IncomeSources.custom;
    } else {
      useCustomSource.value = false;
      selectedSourceKey.value = value;
    }
  }

  Future<void> pickStartDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: startDate.value,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) startDate.value = picked;
  }

  String? _resolvedSource() {
    if (transactionType.value != RecurringTransactionTypes.income) {
      return null;
    }
    if (useCustomSource.value) {
      return customSourceController.text.trim();
    }
    return selectedSourceKey.value;
  }

  RecurringTemplateInput _buildInput() {
    return RecurringTemplateInput(
      transactionType: transactionType.value,
      amount: double.parse(amountController.text.trim()),
      categoryId: transactionType.value == RecurringTransactionTypes.expense
          ? selectedCategoryId.value
          : null,
      source: _resolvedSource(),
      accountId: selectedAccountId.value!,
      frequency: frequency.value,
      startDate: startDate.value,
      notes: notesController.text.trim(),
      isActive: isActive.value,
    );
  }

  Future<void> save() async {
    await runGuarded(() async {
      final input = _buildInput();
      final result = isEditing
          ? await _recurring.update(_templateId!, input)
          : await _recurring.create(input);

      if (result.success) {
        ErrorHandler.popWithSuccess(
          isEditing ? 'recurring_updated'.tr : 'recurring_created'.tr,
        );
      } else if (result.userMessage != null) {
        ErrorHandler.showError(result.userMessage!);
      }
    });
  }
}
