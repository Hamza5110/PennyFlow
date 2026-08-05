import 'package:get/get.dart';

import '../../core/base/base_service.dart';
import '../../core/constants/recurring_constants.dart';
import '../../core/constants/validation_constants.dart';
import '../../core/errors/app_exception.dart';
import '../../core/errors/service_result.dart';
import '../../core/extensions/date_extensions.dart';
import '../../core/utils/recurring_schedule_utils.dart';
import '../../data/models/category.dart';
import '../../data/models/expense/expense_input.dart';
import '../../data/models/income/income_input.dart';
import '../../data/models/recurring/recurring_list_item.dart';
import '../../data/models/recurring/recurring_template_input.dart';
import '../../data/models/recurring_template.dart';
import '../../data/repositories/category_repository.dart';
import '../../data/repositories/expense_repository.dart';
import '../../data/repositories/income_repository.dart';
import '../../data/repositories/payment_account_repository.dart';
import '../../data/repositories/recurring_template_repository.dart';
import '../expense/expense_service.dart';
import '../income/income_service.dart';
import '../notification/notification_service.dart';
import '../settings/settings_service.dart';

class RecurringService extends GetxService with BaseService {
  RecurringService(
    this._templates,
    this._expenses,
    this._incomes,
    this._expenseRepo,
    this._incomeRepo,
    this._categories,
    this._accounts,
    this._notifications,
    this._settings,
  );

  final RecurringTemplateRepository _templates;
  final ExpenseService _expenses;
  final IncomeService _incomes;
  final ExpenseRepository _expenseRepo;
  final IncomeRepository _incomeRepo;
  final CategoryRepository _categories;
  final PaymentAccountRepository _accounts;
  final NotificationService _notifications;
  final SettingsService _settings;

  int? get _profileId => _settings.activeProfileId;

  Future<List<RecurringListItem>> listTemplates({
    String? transactionType,
  }) async {
    final profileId = _profileId;
    if (profileId == null) return [];

    final templates = await _templates.findActiveByProfile(profileId);
    final categories = await _categories.findByProfile(profileId);
    final accounts = await _accounts.findByProfile(profileId);
    final categoryMap = {for (final c in categories) c.id: c};
    final accountMap = {for (final a in accounts) a.id: a};

    final items = <RecurringListItem>[];
    for (final template in templates) {
      if (transactionType != null &&
          template.transactionType != transactionType) {
        continue;
      }
      final label = _labelFor(template, categoryMap);
      items.add(
        RecurringListItem(
          template: template,
          label: label,
          accountName: accountMap[template.accountId]?.name ?? 'Unknown',
        ),
      );
    }
    return items;
  }

  Future<RecurringTemplate?> getById(int id) async {
    final profileId = _profileId;
    if (profileId == null) return null;
    final template = await _templates.findById(id);
    if (template == null ||
        template.profileId != profileId ||
        template.isDeleted) {
      return null;
    }
    return template;
  }

  Future<ServiceResult<RecurringTemplate>> create(
    RecurringTemplateInput input,
  ) async {
    return guard(() async {
      _validateInput(input);
      final profileId = _requireProfileId();
      await _validateRelations(input, profileId);

      final template = RecurringTemplate()
        ..transactionType = input.transactionType
        ..amount = input.amount
        ..categoryId = input.categoryId
        ..source = input.source?.trim().isEmpty == true
            ? null
            : input.source?.trim()
        ..accountId = input.accountId
        ..frequency = input.frequency
        ..notes =
            input.notes?.trim().isEmpty == true ? null : input.notes?.trim()
        ..startDate = input.startDate.startOfDay
        ..nextRunDate = RecurringScheduleUtils.initialNextRun(input.startDate)
        ..isActive = input.isActive
        ..profileId = profileId
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now();

      final id = await _templates.put(template);
      template.id = id;
      return template;
    });
  }

  Future<ServiceResult<RecurringTemplate>> update(
    int id,
    RecurringTemplateInput input,
  ) async {
    return guard(() async {
      _validateInput(input);
      final profileId = _requireProfileId();
      final existing = await _getOwnedTemplate(id, profileId);
      await _validateRelations(input, profileId);

      existing
        ..transactionType = input.transactionType
        ..amount = input.amount
        ..categoryId = input.categoryId
        ..source = input.source?.trim().isEmpty == true
            ? null
            : input.source?.trim()
        ..accountId = input.accountId
        ..frequency = input.frequency
        ..notes =
            input.notes?.trim().isEmpty == true ? null : input.notes?.trim()
        ..startDate = input.startDate.startOfDay
        ..isActive = input.isActive
        ..updatedAt = DateTime.now();

      if (existing.nextRunDate == null ||
          existing.nextRunDate!.isBefore(existing.startDate)) {
        existing.nextRunDate =
            RecurringScheduleUtils.initialNextRun(existing.startDate);
      }

      await _templates.put(existing);
      return existing;
    });
  }

  Future<ServiceResult<void>> pause(int id) async {
    return guardVoid(() async {
      final profileId = _requireProfileId();
      final template = await _getOwnedTemplate(id, profileId);
      template
        ..isActive = false
        ..updatedAt = DateTime.now();
      await _templates.put(template);
    });
  }

  Future<ServiceResult<void>> resume(int id) async {
    return guardVoid(() async {
      final profileId = _requireProfileId();
      final template = await _getOwnedTemplate(id, profileId);
      template
        ..isActive = true
        ..nextRunDate ??=
            RecurringScheduleUtils.initialNextRun(template.startDate)
        ..updatedAt = DateTime.now();
      await _templates.put(template);
    });
  }

  Future<ServiceResult<void>> delete(int id) async {
    return guardVoid(() async {
      final profileId = _requireProfileId();
      final template = await _getOwnedTemplate(id, profileId);
      template
        ..isActive = false
        ..isDeleted = true
        ..deletedAt = DateTime.now()
        ..updatedAt = DateTime.now();
      await _templates.put(template);
    });
  }

  /// Generates due instances and advances schedules (FR-126).
  Future<int> processDueTemplates({DateTime? now}) async {
    final profileId = _profileId;
    if (profileId == null) return 0;

    final reference = now ?? DateTime.now();
    final dueTemplates = await _templates.findDueByProfile(
      profileId,
      through: reference.endOfDay,
    );

    var generated = 0;
    for (final template in dueTemplates) {
      generated += await _processTemplate(template, reference);
    }

    if (generated > 0) {
      await _notifications.showRecurringGenerated(count: generated);
    }

    return generated;
  }

  Future<int> _processTemplate(
    RecurringTemplate template,
    DateTime reference,
  ) async {
    var nextRun = template.nextRunDate ??
        RecurringScheduleUtils.initialNextRun(template.startDate);
    var generated = 0;
    var iterations = 0;

    while (RecurringScheduleUtils.isDue(nextRun, now: reference) &&
        iterations < RecurringScheduleUtils.maxCatchUpPerRun) {
      final created = await _generateInstance(template, nextRun);
      if (created) generated++;
      nextRun = RecurringScheduleUtils.advance(nextRun, template.frequency);
      iterations++;
    }

    template
      ..nextRunDate = nextRun
      ..updatedAt = DateTime.now();
    await _templates.put(template);
    return generated;
  }

  Future<bool> _generateInstance(
    RecurringTemplate template,
    DateTime runDate,
  ) async {
    final profileId = template.profileId;
    final exists = template.transactionType == RecurringTransactionTypes.expense
        ? await _expenseRepo.existsForTemplateOnDate(
            profileId: profileId,
            templateId: template.id,
            date: runDate,
          )
        : await _incomeRepo.existsForTemplateOnDate(
            profileId: profileId,
            templateId: template.id,
            date: runDate,
          );
    if (exists) return false;

    if (template.transactionType == RecurringTransactionTypes.expense) {
      final result = await _expenses.create(
        ExpenseInput(
          amount: template.amount,
          categoryId: template.categoryId!,
          accountId: template.accountId,
          date: runDate,
          notes: template.notes,
        ),
      );
      if (!result.success || result.data == null) return false;
      final expense = result.data!;
      expense.recurringTemplateId = template.id;
      await _expenseRepo.put(expense);
      return true;
    }

    final result = await _incomes.create(
      IncomeInput(
        amount: template.amount,
        source: template.source ?? 'custom',
        accountId: template.accountId,
        date: runDate,
        notes: template.notes,
      ),
    );
    if (!result.success || result.data == null) return false;
    final income = result.data!;
    income.recurringTemplateId = template.id;
    await _incomeRepo.put(income);
    return true;
  }

  String _labelFor(
    RecurringTemplate template,
    Map<int, Category> categoryMap,
  ) {
    if (template.transactionType == RecurringTransactionTypes.income) {
      return template.source ?? 'Income';
    }
    final category = categoryMap[template.categoryId];
    return category?.name ?? 'Expense';
  }

  void _validateInput(RecurringTemplateInput input) {
    if (input.amount <= 0 || input.amount > ValidationConstants.maxAmount) {
      throw const ValidationException(message: 'Invalid amount');
    }
    if (!RecurringTransactionTypes.all.contains(input.transactionType)) {
      throw const ValidationException(message: 'Invalid transaction type');
    }
    if (!RecurringFrequencies.all.contains(input.frequency)) {
      throw const ValidationException(message: 'Invalid frequency');
    }
    if (input.transactionType == RecurringTransactionTypes.expense &&
        input.categoryId == null) {
      throw const ValidationException(message: 'Category is required');
    }
    if (input.transactionType == RecurringTransactionTypes.income &&
        (input.source == null || input.source!.trim().isEmpty)) {
      throw const ValidationException(message: 'Income source is required');
    }
  }

  Future<void> _validateRelations(
    RecurringTemplateInput input,
    int profileId,
  ) async {
    final account = await _accounts.findById(input.accountId);
    if (account == null || account.profileId != profileId) {
      throw const ValidationException(message: 'Invalid account');
    }
    if (input.categoryId != null) {
      final category = await _categories.findById(input.categoryId!);
      if (category == null || category.profileId != profileId) {
        throw const ValidationException(message: 'Invalid category');
      }
    }
  }

  Future<RecurringTemplate> _getOwnedTemplate(int id, int profileId) async {
    final template = await _templates.findById(id);
    if (template == null ||
        template.profileId != profileId ||
        template.isDeleted) {
      throw const NotFoundException(message: 'Recurring template not found');
    }
    return template;
  }

  int _requireProfileId() {
    final profileId = _profileId;
    if (profileId == null) {
      throw const ValidationException(message: 'No active profile');
    }
    return profileId;
  }
}
