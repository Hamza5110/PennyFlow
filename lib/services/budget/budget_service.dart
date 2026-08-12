import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../core/base/base_service.dart';
import '../../core/constants/validation_constants.dart';
import '../../core/errors/app_exception.dart';
import '../../core/errors/service_result.dart';
import '../../core/utils/budget_period_utils.dart';
import '../../data/models/budget.dart';
import '../../data/models/budget/budget_input.dart';
import '../../data/models/budget/budget_list_item.dart';
import '../../data/models/dashboard/budget_progress.dart';
import '../../data/models/enums/app_enums.dart';
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

  /// Active budgets for [reference] (auto-repeat or fixed range containing now).
  Future<List<BudgetListItem>> listActive({DateTime? reference}) async {
    final profileId = _profileId;
    if (profileId == null) return [];

    final now = reference ?? DateTime.now();
    final budgets = await _budgets.findByProfile(profileId);
    final categories = await _categories.findByProfile(profileId);
    final categoryMap = {for (final c in categories) c.id: c};

    final items = <BudgetListItem>[];
    for (final budget in budgets) {
      if (!BudgetPeriodUtils.isActive(budget, reference: now)) continue;

      final window = BudgetPeriodUtils.windowFor(budget, reference: now);
      await _ensureCycleFlags(budget, window);

      final category = categoryMap[budget.categoryId];
      final spent = await _expenses.sumActiveByCategoryInRange(
        profileId: profileId,
        categoryId: budget.categoryId,
        start: window.start,
        end: window.end,
      );
      items.add(
        BudgetListItem(
          budget: budget,
          categoryName: category?.name ?? 'Unknown',
          categoryColorHex: category?.colorHex ?? '#64748B',
          spent: spent,
          window: window,
        ),
      );
    }

    items.sort((a, b) => b.ratio.compareTo(a.ratio));
    return items;
  }

  /// Kept for callers that still pass month filters; returns active budgets.
  Future<List<BudgetListItem>> listForMonth({
    int? year,
    int? month,
    DateTime? reference,
  }) =>
      listActive(reference: reference);

  Future<List<BudgetProgress>> getDashboardProgress({DateTime? reference}) async {
    final items = await listActive(reference: reference);
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
      await _assertNoConflict(profileId, input);

      final budget = Budget()
        ..categoryId = input.categoryId
        ..targetAmount = input.targetAmount
        ..year = input.year
        ..month = input.month
        ..periodType = input.periodType.name
        ..periodStart = BudgetPeriodUtils.startOfDay(input.periodStart)
        ..periodEnd = BudgetPeriodUtils.endOfDay(input.periodEnd)
        ..autoRepeat = input.autoRepeat
        ..lastCycleStart = BudgetPeriodUtils.startOfDay(input.periodStart)
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
      await _assertNoConflict(profileId, input, excludeId: id);

      existing
        ..categoryId = input.categoryId
        ..targetAmount = input.targetAmount
        ..year = input.year
        ..month = input.month
        ..periodType = input.periodType.name
        ..periodStart = BudgetPeriodUtils.startOfDay(input.periodStart)
        ..periodEnd = BudgetPeriodUtils.endOfDay(input.periodEnd)
        ..autoRepeat = input.autoRepeat
        ..lastCycleStart = BudgetPeriodUtils.startOfDay(input.periodStart)
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

    final budgets = await _budgets.findByCategory(
      profileId: profileId,
      categoryId: categoryId,
    );

    for (final budget in budgets) {
      final window = BudgetPeriodUtils.windowFor(budget, reference: date);
      if (!window.contains(date)) continue;

      await _ensureCycleFlags(budget, window);

      final spent = await _expenses.sumActiveByCategoryInRange(
        profileId: profileId,
        categoryId: categoryId,
        start: window.start,
        end: window.end,
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
        continue;
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
  }

  String periodLabel(Budget budget, {DateTime? reference, BudgetPeriodWindow? window}) {
    final type = BudgetPeriodUtils.typeOf(budget);
    final active = window ?? BudgetPeriodUtils.windowFor(budget, reference: reference);
    final fmt = DateFormat('dd MMM');
    final range = '${fmt.format(active.start)} – ${fmt.format(active.end)}';

    final typeLabel = switch (type) {
      BudgetPeriodType.monthly => 'budgets_period_monthly'.tr,
      BudgetPeriodType.days7 => 'budgets_period_days7'.tr,
      BudgetPeriodType.days15 => 'budgets_period_days15'.tr,
      BudgetPeriodType.months3 => 'budgets_period_months3'.tr,
      BudgetPeriodType.custom => 'budgets_period_custom'.tr,
    };

    final repeat = budget.autoRepeat ? ' · ${'budgets_auto_repeat_on'.tr}' : '';
    return '$typeLabel · $range$repeat';
  }

  Future<void> _ensureCycleFlags(Budget budget, BudgetPeriodWindow window) async {
    final last = budget.lastCycleStart;
    if (last != null &&
        last.year == window.start.year &&
        last.month == window.start.month &&
        last.day == window.start.day) {
      return;
    }

    budget
      ..lastCycleStart = window.start
      ..warningNotified = false
      ..exceededNotified = false
      ..year = window.start.year
      ..month = window.start.month
      ..updatedAt = DateTime.now();
    await _budgets.put(budget);
  }

  Future<void> _assertNoConflict(
    int profileId,
    BudgetInput input, {
    int? excludeId,
  }) async {
    final existing = await _budgets.findByCategory(
      profileId: profileId,
      categoryId: input.categoryId,
    );

    for (final budget in existing) {
      if (excludeId != null && budget.id == excludeId) continue;

      if (budget.autoRepeat || input.autoRepeat) {
        throw const ValidationException(
          message:
              'This category already has a budget. Turn off auto-repeat or delete the existing one first.',
          code: 'BUDGET_EXISTS',
          field: 'category',
        );
      }

      if (BudgetPeriodUtils.rangesOverlap(
        budget.periodStart,
        budget.periodEnd,
        input.periodStart,
        input.periodEnd,
      )) {
        throw const ValidationException(
          message: 'A budget already exists for this category in that date range',
          code: 'BUDGET_EXISTS',
          field: 'category',
        );
      }
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
    if (input.warningThreshold <= 0 || input.warningThreshold > 1) {
      throw const ValidationException(
        message: 'Warning threshold must be between 1% and 100%',
        field: 'warningThreshold',
      );
    }
    final start = BudgetPeriodUtils.startOfDay(input.periodStart);
    final end = BudgetPeriodUtils.endOfDay(input.periodEnd);
    if (end.isBefore(start)) {
      throw const ValidationException(
        message: 'End date must be on or after start date',
        field: 'periodEnd',
      );
    }
    if (input.periodType == BudgetPeriodType.custom) {
      final days = end.difference(start).inDays + 1;
      if (days < 1) {
        throw const ValidationException(
          message: 'Custom range must be at least 1 day',
          field: 'periodEnd',
        );
      }
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
