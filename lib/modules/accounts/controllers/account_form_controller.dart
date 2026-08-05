import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/base/base_controller.dart';
import '../../../core/constants/payment_account_types.dart';
import '../../../core/errors/error_handler.dart';
import '../../../data/models/payment_account.dart';
import '../../../data/models/payment_account/payment_account_input.dart';
import '../../../services/payment_account/payment_account_service.dart';
import '../account_routes.dart';

class AccountFormController extends BaseController {
  AccountFormController(this._accounts);

  final PaymentAccountService _accounts;

  final nameController = TextEditingController();
  final openingBalanceController = TextEditingController(text: '0');

  final RxString selectedType = PaymentAccountTypes.cash.obs;

  int? _accountId;
  bool get isEditing => _accountId != null;

  List<({String key, String label})> get typeOptions => [
        for (final key in PaymentAccountTypes.predefinedKeys)
          (key: key, label: PaymentAccountTypes.labelKeys[key]!.tr),
        (key: PaymentAccountTypes.custom, label: 'account_type_custom'.tr),
      ];

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is AccountFormArgs) {
      _accountId = args.accountId;
    }
    _bootstrap();
  }

  @override
  void onClose() {
    nameController.dispose();
    openingBalanceController.dispose();
    super.onClose();
  }

  Future<void> _bootstrap() async {
    final id = _accountId;
    if (id == null) return;

    await runGuarded(() async {
      final account = await _accounts.getById(id);
      if (account == null) {
        ErrorHandler.showError('accounts_not_found'.tr);
        Get.back<void>();
        return;
      }
      _populate(account);
    }, showErrorSnackbar: false);
  }

  void _populate(PaymentAccount account) {
    nameController.text = account.name;
    selectedType.value = account.type;
    openingBalanceController.text = account.openingBalance.toStringAsFixed(2);
  }

  void onTypeChanged(String? type) {
    if (type != null) selectedType.value = type;
  }

  PaymentAccountInput _buildInput() {
    return PaymentAccountInput(
      name: nameController.text.trim(),
      type: selectedType.value,
      openingBalance: double.parse(openingBalanceController.text.trim()),
    );
  }

  Future<void> save() async {
    await runGuarded(() async {
      final input = _buildInput();
      final result = isEditing
          ? await _accounts.update(_accountId!, input)
          : await _accounts.create(input);

      if (result.success) {
        ErrorHandler.showSuccess(
          isEditing ? 'accounts_updated'.tr : 'accounts_created'.tr,
        );
        Get.back(result: true);
        return;
      } else if (result.userMessage != null) {
        ErrorHandler.showError(result.userMessage!);
      }
    });
  }
}
