import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/base/base_controller.dart';
import '../../../core/errors/error_handler.dart';
import '../../../data/models/payment_account/payment_account_list_item.dart';
import '../../../services/payment_account/payment_account_service.dart';
import '../account_routes.dart';

class AccountsListController extends BaseController {
  AccountsListController(this._accounts);

  final PaymentAccountService _accounts;

  final RxList<PaymentAccountListItem> activeItems =
      <PaymentAccountListItem>[].obs;
  final RxList<PaymentAccountListItem> archivedItems =
      <PaymentAccountListItem>[].obs;
  final RxBool showArchived = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadAccounts();
  }

  Future<void> loadAccounts() async {
    await runGuarded(() async {
      activeItems.assignAll(await _accounts.listActiveWithBalances());
      archivedItems.assignAll(await _accounts.listArchivedWithBalances());
    }, showErrorSnackbar: false);
  }

  void toggleArchived() => showArchived.toggle();

  void openAdd() {
    Get.toNamed<void>(AppRoutes.accountForm)?.then((_) => loadAccounts());
  }

  void openEdit(PaymentAccountListItem item) {
    Get.toNamed<void>(
      AppRoutes.accountForm,
      arguments: AccountFormArgs(accountId: item.account.id),
    )?.then((_) => loadAccounts());
  }

  Future<void> archiveAccount(PaymentAccountListItem item) async {
    await runGuarded(() async {
      final result = await _accounts.archive(item.account.id);
      if (result.success) {
        ErrorHandler.showSuccess('accounts_archived'.tr);
        await loadAccounts();
      } else if (result.userMessage != null) {
        ErrorHandler.showError(result.userMessage!);
      }
    });
  }

  Future<void> unarchiveAccount(PaymentAccountListItem item) async {
    await runGuarded(() async {
      final result = await _accounts.unarchive(item.account.id);
      if (result.success) {
        ErrorHandler.showSuccess('accounts_unarchived'.tr);
        await loadAccounts();
      } else if (result.userMessage != null) {
        ErrorHandler.showError(result.userMessage!);
      }
    });
  }

  Future<void> deleteAccount(PaymentAccountListItem item) async {
    if (item.account.isDefault) {
      ErrorHandler.showError('accounts_default_delete_blocked'.tr);
      return;
    }

    if (item.transactionCount > 0) {
      ErrorHandler.showError('accounts_delete_in_use'.tr);
      return;
    }

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text('accounts_delete_title'.tr),
        content: Text(
          'accounts_delete_confirm'.trParams({'name': item.account.name}),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('common_cancel'.tr),
          ),
          FilledButton(
            onPressed: () => Get.back(result: true),
            child: Text('common_delete'.tr),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await runGuarded(() async {
      final result = await _accounts.delete(item.account.id);
      if (result.success) {
        ErrorHandler.showSuccess('accounts_deleted'.tr);
        await loadAccounts();
      } else if (result.userMessage != null) {
        ErrorHandler.showError(result.userMessage!);
      }
    });
  }
}
