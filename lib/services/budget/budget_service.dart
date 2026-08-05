import 'package:get/get.dart';

import '../../core/base/base_service.dart';
import '../../core/constants/validation_constants.dart';
import '../../core/errors/app_exception.dart';
import '../../core/errors/service_result.dart';
import '../../data/models/budget.dart';
import '../../data/models/budget/budget_input.dart';
import '../../data/models/budget/budget_list_item.dart';
import '../../data/models/dashboard/budget_progress.dart';
import '../../data/repositories/budget_repository.dart';
import '../../data/repositories/category_repository.dart';
import '../../data/repositories/expense_repository.dart';
import '../notification/notification_service.dart';
import '../settings/settings_service.dart';

class BudgetService extends GetxService with BaseService {
  BudgetService(
    this._budgets,
    this._expenses,
    this._categories,
    this._notifications,
    this._settings,
  );

  final BudgetRepository _budgets;
  final ExpenseRepository _expenses;
  final CategoryRepository _categories;
  final NotificationService _notifications;
  final SettingsService _settings;

  int? get _profileId => _settings.activeProfileId;

  Future<List<BudgetListItem>> listForMonth({
    int? year,
    int? month,
    DateTime? reference,
  }) async {
    final profileId = _profileId;
    if (profileId == null) return [];

    final now = reference ?? DateTime.now();
    final y = year ?? now.year;
    final m = month ?? now.month;

    final budgets = await _budgets.findByProfileAndMonth(profileId, y, m);
    final categories = await _categories.findByProfile(profileId);
    final categoryMap = {for (final c in categories) c.id: c};

    final items = <BudgetListItem>[];
    for (final budget in budgets) {
      final category = categoryMap[budget.categoryId];
      final spent = await _expenses.sumActiveByCategoryInMonth(
        profileId: profileId,
        categoryId: budget.categoryId,
        year: y,
        month: m,
      );
      items.add(
        BudgetListItem(
          budget: budget,
          categoryName: category?.name ?? 'Unknown',
          categoryColorHex: category?.colorHex ?? '#64748B',
          spent: spent,
        ),
      );
    }

    items.sort((a, b) => b.ratio.compareTo(a.ratio));
    return items;
  }

  Future<List<BudgetProgress>> getDashboardProgress({DateTime? reference}) async {
    final items = await listForMonth(reference: reference);
    return items
        .map(
          (item) => BudgetProgress(
            budgetId: item.budget.id,
            categoryName: item.categoryName,
            colorHex: item.categoryColorHex,
            spent: item.spent,
            target: item.target,
            warningThreshold: item.budget.warningThreshold,
          ),
        )
        .toList();
  }

  Future<Budget?> getById(int id) async {
    final profileId = _profileId;
    if (profileId == null) return null;
    final budget = await _budgets.findById(id);
    if (budget == null || budget.profileId != profileId) return null;
    return budget;
  }

  Future<ServiceResult<Budget>> create(BudgetInput input) async {
    return guard(() async {
      final profileId = _requireProfileId();
      _validateInput(input);
      await _validateCategory(input.categoryId, profileId);

      final existing = await _budgets.findByCategoryMonth(
        profileId: profileId,
        categoryId: input.categoryId,
        year: input.year,
        month: input.month,
      );
      if (existing != null) {
        throw const ValidationException(
          message: 'A budget already exists for this category this month',
          code: 'BUDGET_EXISTS',
          field: 'category',
        );
      }

      final budget = Budget()
        ..categoryId = input.categoryId
        ..targetAmount = input.targetAmount
        ..year = input.year
        ..month = input.month
        ..warningThreshold = input.warningThreshold
        ..profileId = profileId;

      final id = await _budgets.put(budget);
      budget.id = id;
      return budget;
    });
  }

  Future<ServiceResult<Budget>> update(int id, BudgetInput input) async {
    return guard(() async {
      final profileId = _requireProfileId();
      _validateInput(input);
      final existing = await _getOwnedBudget(id, profileId);
      await _validateCategory(input.categoryId, profileId);

      final duplicate = await _budgets.findByCategoryMonth(
        profileId: profileId,
        categoryId: input.categoryId,
        year: input.year,
        month: input.month,
      );
      if (duplicate != null && duplicate.id != id) {
        throw const ValidationException(
          message: 'A budget already exists for this category this month',
          code: 'BUDGET_EXISTS',
          field: 'category',
        );
      }

      existing
        ..categoryId = input.categoryId
        ..targetAmount = input.targetAmount
        ..year = input.year
        ..month = input.month
        ..warningThreshold = input.warningThreshold
        ..warningNotified = false
        ..exceededNotified = false
        ..updatedAt = DateTime.now();

      await _budgets.put(existing);
      return existing;
    });
  }

  Future<ServiceResult<void>> delete(int id) async {
    return guardVoid(() async {
      final profileId = _requireProfileId();
      await _getOwnedBudget(id, profileId);
      await _budgets.deleteById(id);
    });
  }

  /// Re-evaluate alerts after an expense changes (FR-080–FR-082).
  Future<void> onExpenseChanged(int categoryId, DateTime date) async {
    final profileId = _profileId;
    if (profileId == null || !_settings.budgetAlertsEnabled.value) return;

    final budget = await _budgets.findByCategoryMonth(
      profileId: profileId,
      categoryId: categoryId,
      year: date.year,
      month: date.month,
    );
    if (budget == null) return;

    final spent = await _expenses.sumActiveByCategoryInMonth(
      profileId: profileId,
      categoryId: categoryId,
      year: date.year,
      month: date.month,
    );

    final ratio = budget.targetAmount <= 0 ? 0 : spent / budget.targetAmount;
    final category = await _categories.findById(categoryId);
    final categoryName = category?.name ?? 'Category';

    if (ratio >= 1.0 && !budget.exceededNotified) {
      await _notifications.showBudgetExceeded(
        budgetId: budget.id,
        categoryName: categoryName,
        spent: spent,
        target: budget.targetAmount,
      );
      budget
        ..exceededNotified = true
        ..warningNotified = true
        ..updatedAt = DateTime.now();
      await _budgets.put(budget);
      return;
    }

    if (ratio >= budget.warningThreshold && !budget.warningNotified) {
      await _notifications.showBudgetWarning(
        budgetId: budget.id,
        categoryName: categoryName,
        spent: spent,
        target: budget.targetAmount,
      );
      budget
        ..warningNotified = true
        ..updatedAt = DateTime.now();
      await _budgets.put(budget);
    }

    if (ratio < budget.warningThreshold &&
        budget.warningNotified &&
        !budget.exceededNotified) {
      budget
        ..warningNotified = false
        ..updatedAt = DateTime.now();
      await _budgets.put(budget);
    }

    if (ratio < 1.0 && budget.exceededNotified) {
      budget
        ..exceededNotified = false
        ..updatedAt = DateTime.now();
      await _budgets.put(budget);
    }
  }

  void _validateInput(BudgetInput input) {
    if (input.targetAmount < ValidationConstants.minAmount ||
        input.targetAmount > ValidationConstants.maxAmount) {
      throw const ValidationException(
        message: 'Enter a valid budget amount',
        field: 'targetAmount',
      );
    }
    if (input.month < 1 || input.month > 12) {
      throw const ValidationException(message: 'Invalid month', field: 'month');
    }
    if (input.warningThreshold <= 0 || input.warningThreshold > 1) {
      throw const ValidationException(
        message: 'Warning threshold must be between 1% and 100%',
        field: 'warningThreshold',
      );
    }
  }

  Future<void> _validateCategory(int categoryId, int profileId) async {
    final category = await _categories.findById(categoryId);
    if (category == null || category.profileId != profileId) {
      throw const NotFoundException(message: 'Category not found');
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

  Future<Budget> _getOwnedBudget(int id, int profileId) async {
    final budget = await _budgets.getOrThrow(id);
    if (budget.profileId != profileId) {
      throw const NotFoundException(message: 'Budget not found');
    }
    return budget;
  }
}
