import 'package:get/get.dart';

import '../../core/base/base_service.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/validation_constants.dart';
import '../../core/errors/app_exception.dart';
import '../../core/errors/service_result.dart';
import '../../core/utils/app_date_utils.dart';
import '../../core/utils/search_match_utils.dart';
import '../../data/models/expense.dart';
import '../../data/models/expense/expense_filter.dart';
import '../../data/models/expense/expense_input.dart';
import '../../data/models/expense/expense_list_item.dart';
import '../../data/repositories/expense_repository.dart';
import '../budget/budget_service.dart';
import '../category/category_service.dart';
import '../image/image_service.dart';
import '../payment_account/payment_account_service.dart';
import '../settings/settings_service.dart';

class ExpenseService extends GetxService with BaseService {
  ExpenseService(
    this._expenses,
    this._categories,
    this._accounts,
    this._images,
    this._settings,
  );

  final ExpenseRepository _expenses;
  final CategoryService _categories;
  final PaymentAccountService _accounts;
  final ImageService _images;
  final SettingsService _settings;

  int? get _profileId => _settings.activeProfileId;

  Future<ServiceResult<Expense>> create(ExpenseInput input) async {
    return guard(() async {
      _validateInput(input);
      final profileId = _requireProfileId();
      await _validateRelations(input, profileId);

      final expense = Expense()
        ..amount = input.amount
        ..categoryId = input.categoryId
        ..accountId = input.accountId
        ..date = input.date
        ..notes = input.notes?.trim().isEmpty == true ? null : input.notes?.trim()
        ..tags = input.tags
        ..location =
            input.location?.trim().isEmpty == true ? null : input.location?.trim()
        ..receiptImagePaths = List.of(input.receiptImagePaths)
        ..profileId = profileId
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now();

      final id = await _expenses.put(expense);
      expense.id = id;
      await _notifyBudgetChange(expense.categoryId, expense.date);
      return expense;
    });
  }

  Future<ServiceResult<Expense>> update(int id, ExpenseInput input) async {
    return guard(() async {
      _validateInput(input);
      final profileId = _requireProfileId();
      final existing = await _getOwnedExpense(id, profileId);
      await _validateRelations(input, profileId);
      final previousCategoryId = existing.categoryId;
      final previousDate = existing.date;

      final previousPaths = List<String>.from(existing.receiptImagePaths);

      existing
        ..amount = input.amount
        ..categoryId = input.categoryId
        ..accountId = input.accountId
        ..date = input.date
        ..notes = input.notes?.trim().isEmpty == true ? null : input.notes?.trim()
        ..tags = input.tags
        ..location =
            input.location?.trim().isEmpty == true ? null : input.location?.trim()
        ..receiptImagePaths = List.of(input.receiptImagePaths)
        ..updatedAt = DateTime.now();

      await _images.deleteRemovedPaths(
        previous: previousPaths,
        current: input.receiptImagePaths,
      );
      await _expenses.put(existing);
      await _notifyBudgetChange(existing.categoryId, existing.date);
      if (previousCategoryId != existing.categoryId ||
          previousDate.year != existing.date.year ||
          previousDate.month != existing.date.month) {
        await _notifyBudgetChange(previousCategoryId, previousDate);
      }
      return existing;
    });
  }

  Future<ServiceResult<Expense>> duplicate(int id) async {
    final profileId = _profileId;
    if (profileId == null) {
      return ServiceResult.failure(userMessage: 'No active profile');
    }
    try {
      final source = await _getOwnedExpense(id, profileId);
      return create(
        ExpenseInput(
          amount: source.amount,
          categoryId: source.categoryId,
          accountId: source.accountId,
          date: DateTime.now(),
          notes: source.notes,
          tags: List.of(source.tags),
          location: source.location,
          receiptImagePaths: List.of(source.receiptImagePaths),
        ),
      );
    } on AppException catch (error) {
      return ServiceResult.failure(
        userMessage: error.message,
        errorCode: error.code,
        exception: error,
      );
    } catch (error, stackTrace) {
      log.e('Duplicate expense failed', error: error, stackTrace: stackTrace);
      return ServiceResult.failure(userMessage: 'Could not duplicate expense');
    }
  }

  Future<ServiceResult<void>> softDelete(int id) async {
    return guardVoid(() async {
      final profileId = _requireProfileId();
      final expense = await _getOwnedExpense(id, profileId);
      expense
        ..isDeleted = true
        ..deletedAt = DateTime.now()
        ..updatedAt = DateTime.now();
      await _expenses.put(expense);
      await _notifyBudgetChange(expense.categoryId, expense.date);
    });
  }

  Future<ServiceResult<void>> restore(int id) async {
    return guardVoid(() async {
      final profileId = _requireProfileId();
      final expense = await _expenses.getOrThrow(id);
      if (expense.profileId != profileId) {
        throw const NotFoundException(message: 'Expense not found');
      }
      expense
        ..isDeleted = false
        ..deletedAt = null
        ..updatedAt = DateTime.now();
      await _expenses.put(expense);
      await _notifyBudgetChange(expense.categoryId, expense.date);
    });
  }

  Future<ServiceResult<void>> permanentDelete(int id) async {
    return guardVoid(() async {
      final profileId = _requireProfileId();
      final expense = await _expenses.getOrThrow(id);
      if (expense.profileId != profileId || !expense.isDeleted) {
        throw const NotFoundException(message: 'Expense not in trash');
      }
      final categoryId = expense.categoryId;
      final date = expense.date;
      await _images.deleteImages(expense.receiptImagePaths);
      await _expenses.deleteById(id);
      await _notifyBudgetChange(categoryId, date);
    });
  }

  Future<Expense?> getById(int id) async {
    final profileId = _profileId;
    if (profileId == null) return null;
    final expense = await _expenses.findById(id);
    if (expense == null || expense.profileId != profileId) return null;
    return expense;
  }

  Future<List<ExpenseListItem>> listActive({ExpenseFilter filter = ExpenseFilter.empty}) async {
    final profileId = _profileId;
    if (profileId == null) return [];

    final categories = await _categories.getCategories();
    final accounts = await _accounts.getActiveAccounts();
    final categoryMap = {for (final c in categories) c.id: c};
    final accountMap = {for (final a in accounts) a.id: a};

    var expenses = await _expenses.findActiveByProfile(profileId);
    expenses = _applyFilter(expenses, filter, categoryMap, accountMap);

    return expenses.map((expense) {
      final category = categoryMap[expense.categoryId];
      final account = accountMap[expense.accountId];
      return ExpenseListItem(
        expense: expense,
        categoryName: category?.name ?? 'Unknown',
        categoryColorHex: category?.colorHex ?? '#64748B',
        accountName: account?.name ?? 'Unknown',
      );
    }).toList();
  }

  Future<List<ExpenseListItem>> listTrash() async {
    final profileId = _profileId;
    if (profileId == null) return [];

    final categories = await _categories.getCategories();
    final accounts = await _accounts.getActiveAccounts();
    final categoryMap = {for (final c in categories) c.id: c};
    final accountMap = {for (final a in accounts) a.id: a};

    final expenses = await _expenses.findDeletedByProfile(profileId);
    return expenses.map((expense) {
      final category = categoryMap[expense.categoryId];
      final account = accountMap[expense.accountId];
      return ExpenseListItem(
        expense: expense,
        categoryName: category?.name ?? 'Unknown',
        categoryColorHex: category?.colorHex ?? '#64748B',
        accountName: account?.name ?? 'Unknown',
      );
    }).toList();
  }

  List<Expense> _applyFilter(
    List<Expense> expenses,
    ExpenseFilter filter,
    Map<int, dynamic> categoryMap,
    Map<int, dynamic> accountMap,
  ) {
    var result = expenses;

    if (filter.categoryId != null) {
      result = result.where((e) => e.categoryId == filter.categoryId).toList();
    }
    if (filter.accountId != null) {
      result = result.where((e) => e.accountId == filter.accountId).toList();
    }
    if (filter.tag != null && filter.tag!.isNotEmpty) {
      final tag = filter.tag!.toLowerCase();
      result = result
          .where((e) => e.tags.any((t) => t.toLowerCase().contains(tag)))
          .toList();
    }

    DateRange? range = AppDateUtils.resolveFilterRange(
      period: filter.datePeriod,
      customRange: filter.customRange,
    );
    if (range != null) {
      result = result.where((e) => range.contains(e.date)).toList();
    }

    final query = filter.searchQuery.trim();
    if (query.isNotEmpty) {
      result = result.where((e) {
        final category = categoryMap[e.categoryId];
        final account = accountMap[e.accountId];
        return SearchMatchUtils.matches(
          query,
          [
            e.amount.toString(),
            e.amount.toStringAsFixed(2),
            e.notes ?? '',
            e.location ?? '',
            category?.name ?? '',
            account?.name ?? '',
            ...e.tags,
          ],
          date: e.date,
        );
      }).toList();
    }

    return result;
  }

  void _validateInput(ExpenseInput input) {
    if (input.amount < ValidationConstants.minAmount ||
        input.amount > ValidationConstants.maxAmount) {
      throw const ValidationException(
        message: 'Enter a valid amount',
        field: 'amount',
      );
    }
    if (input.notes != null && input.notes!.length > AppConstants.maxNotesLength) {
      throw ValidationException(
        message: 'Notes must be at most ${AppConstants.maxNotesLength} characters',
        field: 'notes',
      );
    }
    if (input.tags.length > AppConstants.maxTagsPerTransaction) {
      throw ValidationException(
        message: 'Maximum ${AppConstants.maxTagsPerTransaction} tags allowed',
        field: 'tags',
      );
    }
    for (final tag in input.tags) {
      if (tag.length > AppConstants.maxTagLength) {
        throw ValidationException(
          message: 'Each tag must be at most ${AppConstants.maxTagLength} characters',
          field: 'tags',
        );
      }
    }
    if (input.receiptImagePaths.length > AppConstants.maxImagesPerTransaction) {
      throw ValidationException(
        message: 'Maximum ${AppConstants.maxImagesPerTransaction} images allowed',
        field: 'images',
      );
    }
  }

  Future<void> _validateRelations(ExpenseInput input, int profileId) async {
    final category = await _categories.getById(input.categoryId);
    if (category == null || category.profileId != profileId) {
      throw const ValidationException(
        message: 'Select a valid category',
        field: 'category',
      );
    }
    final account = await _accounts.getById(input.accountId);
    if (account == null || account.profileId != profileId) {
      throw const ValidationException(
        message: 'Select a valid payment account',
        field: 'account',
      );
    }
  }

  int _requireProfileId() {
    final id = _profileId;
    if (id == null) {
      throw const NotFoundException(
        message: 'No active profile',
        code: 'PROFILE_NOT_FOUND',
      );
    }
    return id;
  }

  Future<Expense> _getOwnedExpense(int id, int profileId) async {
    final expense = await _expenses.getOrThrow(id);
    if (expense.profileId != profileId || expense.isDeleted) {
      throw const NotFoundException(message: 'Expense not found');
    }
    return expense;
  }

  Future<void> _notifyBudgetChange(int categoryId, DateTime date) async {
    if (!Get.isRegistered<BudgetService>()) return;
    await Get.find<BudgetService>().onExpenseChanged(categoryId, date);
  }
}
