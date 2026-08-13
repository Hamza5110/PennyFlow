import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spend_vault/core/constants/app_constants.dart';
import 'package:spend_vault/data/models/category.dart';
import 'package:spend_vault/data/models/expense.dart';
import 'package:spend_vault/data/models/payment_account.dart';
import 'package:spend_vault/data/repositories/category_repository.dart';
import 'package:spend_vault/data/repositories/expense_repository.dart';
import 'package:spend_vault/data/repositories/income_repository.dart';
import 'package:spend_vault/data/repositories/payment_account_repository.dart';
import 'package:spend_vault/modules/expenses/controllers/expenses_list_controller.dart';
import 'package:spend_vault/services/category/category_service.dart';
import 'package:spend_vault/services/expense/expense_service.dart';
import 'package:spend_vault/services/image/image_service.dart';
import 'package:spend_vault/services/payment_account/payment_account_service.dart';
import 'package:spend_vault/services/search/filter_session_service.dart';
import 'package:spend_vault/services/settings/settings_service.dart';
import 'package:spend_vault/services/storage/local_storage_service.dart';

import '../support/isar_test_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late TestIsarHarness harness;
  ExpensesListController? controller;

  setUp(() async {
    Get.reset();
    SharedPreferences.setMockInitialValues({});
    harness = await TestIsarHarness.open();

    final localStorage = LocalStorageService();
    await localStorage.init();
    final settings = SettingsService(localStorage);
    await settings.init();
    await settings.setActiveProfileId(1);
    Get.put<SettingsService>(settings);

    final categories = CategoryRepository(harness.db);
    final categoryId = await categories.put(
      Category()
        ..name = 'Food'
        ..colorHex = '#F97316'
        ..iconKey = 'restaurant'
        ..profileId = 1,
    );

    final accounts = PaymentAccountRepository(harness.db);
    final accountId = await accounts.put(
      PaymentAccount()
        ..name = 'Cash'
        ..type = 'cash'
        ..openingBalance = 0
        ..profileId = 1,
    );

    final expenses = ExpenseRepository(harness.db);
    for (var i = 1; i <= AppConstants.listPageSize + 3; i++) {
      await expenses.put(
        Expense()
          ..profileId = 1
          ..amount = i.toDouble()
          ..categoryId = categoryId
          ..accountId = accountId
          ..date = DateTime(2026, 3, i),
      );
    }

    final categoryService = CategoryService(
      categories,
      expenses,
      settings,
    );
    await categoryService.init();

    final accountService = PaymentAccountService(
      accounts,
      expenses,
      IncomeRepository(harness.db),
      settings,
    );
    await accountService.init();

    final expenseService = ExpenseService(
      expenses,
      categoryService,
      accountService,
      ImageService(),
      settings,
    );
    Get.put(expenseService);
    Get.put(FilterSessionService());

    controller = ExpensesListController(
      expenseService,
      Get.find<FilterSessionService>(),
    );
    Get.put(controller);
  });

  tearDown(() async {
    controller?.onClose();
    Get.reset();
    await harness.dispose();
  });

  group('ExpensesListController', () {
    test('loadExpenses loads first page only', () async {
      await controller!.loadExpenses();

      expect(controller!.items.length, AppConstants.listPageSize);
      expect(controller!.hasMore.value, isTrue);
    });

    test('loadMore appends next page', () async {
      await controller!.loadExpenses();
      await controller!.loadMore();

      expect(controller!.items.length, AppConstants.listPageSize + 3);
      expect(controller!.hasMore.value, isFalse);
    });
  });
}
