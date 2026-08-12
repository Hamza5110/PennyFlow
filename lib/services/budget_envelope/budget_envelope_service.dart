import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../core/base/base_service.dart';
import '../../core/constants/validation_constants.dart';
import '../../core/errors/app_exception.dart';
import '../../core/errors/service_result.dart';
import '../../core/utils/budget_period_utils.dart';
import '../../data/models/budget_envelope.dart';
import '../../data/models/budget_envelope/budget_envelope_input.dart';
import '../../data/models/budget_envelope/budget_envelope_list_item.dart';
import '../../data/models/dashboard/budget_progress.dart';
import '../../data/models/enums/app_enums.dart';
import '../../data/models/income/income_input.dart';
import '../../data/repositories/budget_envelope_repository.dart';
import '../../data/repositories/expense_repository.dart';
import '../../data/repositories/payment_account_repository.dart';
import '../income/income_service.dart';
import '../notification/notification_service.dart';
import '../settings/settings_service.dart';

class BudgetEnvelopeService extends GetxService with BaseService {
  BudgetEnvelopeService(
    this._envelopes,
    this._expenses,
    this._accounts,
    this._incomes,
    this._notifications,
    this._settings,
  );

  final BudgetEnvelopeRepository _envelopes;
  final ExpenseRepository _expenses;
  final PaymentAccountRepository _accounts;
  final IncomeService _incomes;
  final NotificationService _notifications;
  final SettingsService _settings;

  static const double _amountEpsilon = 0.009;
  static const String fundingIncomeSource = 'Budget envelope funding';
  static const String envelopeColorHex = '#0D9488';

  int? get _profileId => _settings.activeProfileId;

  Future<List<BudgetEnvelopeListItem>> listActive({DateTime? reference}) async {
    final profileId = _profileId;
    if (profileId == null) return [];

    final now = reference ?? DateTime.now();
    final envelopes = await _envelopes.findByProfile(profileId);
    final accounts = await _accounts.findByProfile(profileId);
    final accountMap = {for (final a in accounts) a.id: a};

    final items = <BudgetEnvelopeListItem>[];
    for (final envelope in envelopes) {
      if (!BudgetPeriodUtils.isEnvelopeActive(envelope, reference: now)) {
        continue;
      }

      final window = BudgetPeriodUtils.windowForEnvelope(
        envelope,
        reference: now,
      );
      await _ensureCycleFlags(envelope, window);
      await _maybePostCycleFunding(envelope, window);

      final spent = await _expenses.sumActiveInRange(
        profileId: profileId,
        start: window.start,
        end: window.end,
      );

      final fundingProgress = <EnvelopeFundingProgress>[];
      for (final split in envelope.fundingSplits) {
        final accountSpent = await _expenses.sumActiveByAccountInRange(
          profileId: profileId,
          accountId: split.accountId,
          start: window.start,
          end: window.end,
        );
        final account = accountMap[split.accountId];
        fundingProgress.add(
          EnvelopeFundingProgress(
            accountId: split.accountId,
            accountName: account?.name ?? 'Unknown',
            funded: split.amount,
            spent: accountSpent,
          ),
        );
      }

      items.add(
        BudgetEnvelopeListItem(
          envelope: envelope,
          spent: spent,
          window: window,
          fundingProgress: fundingProgress,
        ),
      );
    }

    items.sort((a, b) => b.ratio.compareTo(a.ratio));
    return items;
  }

  Future<List<BudgetProgress>> getDashboardProgress({DateTime? reference}) async {
    final items = await listActive(reference: reference);
    return items
        .map(
          (item) => BudgetProgress(
            budgetId: item.envelope.id,
            categoryName: 'envelope_dashboard_label'.tr,
            colorHex: envelopeColorHex,
            spent: item.spent,
            target: item.target,
            warningThreshold: item.envelope.warningThreshold,
            isEnvelope: true,
          ),
        )
        .toList();
  }

  Future<BudgetEnvelope?> getById(int id) async {
    final profileId = _profileId;
    if (profileId == null) return null;
    final envelope = await _envelopes.findById(id);
    if (envelope == null || envelope.profileId != profileId) return null;
    return envelope;
  }

  Future<ServiceResult<BudgetEnvelope>> create(BudgetEnvelopeInput input) async {
    return guard(() async {
      final profileId = _requireProfileId();
      await _validateInput(input, profileId);
      await _assertNoConflict(profileId, input);

      final start = BudgetPeriodUtils.startOfDay(input.periodStart);
      final envelope = BudgetEnvelope()
        ..totalAmount = input.totalAmount
        ..periodType = input.periodType.name
        ..periodStart = start
        ..periodEnd = BudgetPeriodUtils.endOfDay(input.periodEnd)
        ..autoRepeat = input.autoRepeat
        ..warningThreshold = input.warningThreshold
        ..lastCycleStart = start
        ..categoryAllocations = []
        ..fundingSplits = _mapFundingSplits(input)
        ..profileId = profileId;

      final id = await _envelopes.put(envelope);
      envelope.id = id;

      if (input.recordFundingAsIncome) {
        final window = BudgetPeriodUtils.windowForEnvelope(envelope);
        await _postFundingIncome(envelope, window.start);
        envelope.lastFundingCycleStart = window.start;
        envelope.updatedAt = DateTime.now();
        await _envelopes.put(envelope);
      }

      return envelope;
    });
  }

  Future<ServiceResult<BudgetEnvelope>> update(
    int id,
    BudgetEnvelopeInput input,
  ) async {
    return guard(() async {
      final profileId = _requireProfileId();
      await _validateInput(input, profileId);
      final existing = await _getOwned(id, profileId);
      await _assertNoConflict(profileId, input, excludeId: id);

      final start = BudgetPeriodUtils.startOfDay(input.periodStart);
      existing
        ..totalAmount = input.totalAmount
        ..periodType = input.periodType.name
        ..periodStart = start
        ..periodEnd = BudgetPeriodUtils.endOfDay(input.periodEnd)
        ..autoRepeat = input.autoRepeat
        ..lastCycleStart = start
        ..warningThreshold = input.warningThreshold
        ..warningNotified = false
        ..exceededNotified = false
        ..categoryAllocations = []
        ..fundingSplits = _mapFundingSplits(input)
        ..updatedAt = DateTime.now();

      await _envelopes.put(existing);

      if (input.recordFundingAsIncome) {
        final window = BudgetPeriodUtils.windowForEnvelope(existing);
        await _postFundingIncome(existing, window.start);
        existing
          ..lastFundingCycleStart = window.start
          ..updatedAt = DateTime.now();
        await _envelopes.put(existing);
      }

      return existing;
    });
  }

  Future<ServiceResult<void>> delete(int id) async {
    return guardVoid(() async {
      final profileId = _requireProfileId();
      await _getOwned(id, profileId);
      await _envelopes.deleteById(id);
    });
  }

  /// Re-evaluate envelope alerts after an expense changes.
  Future<void> onExpenseChanged(DateTime date) async {
    final profileId = _profileId;
    if (profileId == null || !_settings.budgetAlertsEnabled.value) return;

    final envelopes = await _envelopes.findByProfile(profileId);
    for (final envelope in envelopes) {
      final window = BudgetPeriodUtils.windowForEnvelope(
        envelope,
        reference: date,
      );
      if (!window.contains(date)) continue;

      await _ensureCycleFlags(envelope, window);

      final spent = await _expenses.sumActiveInRange(
        profileId: profileId,
        start: window.start,
        end: window.end,
      );

      final ratio =
          envelope.totalAmount <= 0 ? 0.0 : spent / envelope.totalAmount;

      if (ratio >= 1.0 && !envelope.exceededNotified) {
        await _notifications.showEnvelopeExceeded(
          envelopeId: envelope.id,
          spent: spent,
          target: envelope.totalAmount,
        );
        envelope
          ..exceededNotified = true
          ..warningNotified = true
          ..updatedAt = DateTime.now();
        await _envelopes.put(envelope);
        continue;
      }

      if (ratio >= envelope.warningThreshold && !envelope.warningNotified) {
        await _notifications.showEnvelopeWarning(
          envelopeId: envelope.id,
          spent: spent,
          target: envelope.totalAmount,
        );
        envelope
          ..warningNotified = true
          ..updatedAt = DateTime.now();
        await _envelopes.put(envelope);
      }

      if (ratio < envelope.warningThreshold &&
          envelope.warningNotified &&
          !envelope.exceededNotified) {
        envelope
          ..warningNotified = false
          ..updatedAt = DateTime.now();
        await _envelopes.put(envelope);
      }

      if (ratio < 1.0 && envelope.exceededNotified) {
        envelope
          ..exceededNotified = false
          ..updatedAt = DateTime.now();
        await _envelopes.put(envelope);
      }
    }
  }

  String periodLabel(
    BudgetEnvelope envelope, {
    DateTime? reference,
    BudgetPeriodWindow? window,
  }) {
    final type = BudgetPeriodUtils.typeOfEnvelope(envelope);
    final active =
        window ?? BudgetPeriodUtils.windowForEnvelope(envelope, reference: reference);
    final fmt = DateFormat('dd MMM');
    final range = '${fmt.format(active.start)} – ${fmt.format(active.end)}';

    final typeLabel = switch (type) {
      BudgetPeriodType.monthly => 'budgets_period_monthly'.tr,
      BudgetPeriodType.days7 => 'budgets_period_days7'.tr,
      BudgetPeriodType.days15 => 'budgets_period_days15'.tr,
      BudgetPeriodType.months3 => 'budgets_period_months3'.tr,
      BudgetPeriodType.custom => 'budgets_period_custom'.tr,
    };

    final repeat = envelope.autoRepeat ? ' · ${'budgets_auto_repeat_on'.tr}' : '';
    return '$typeLabel · $range$repeat';
  }

  Future<void> _ensureCycleFlags(
    BudgetEnvelope envelope,
    BudgetPeriodWindow window,
  ) async {
    final last = envelope.lastCycleStart;
    if (last != null &&
        last.year == window.start.year &&
        last.month == window.start.month &&
        last.day == window.start.day) {
      return;
    }

    envelope
      ..lastCycleStart = window.start
      ..warningNotified = false
      ..exceededNotified = false
      ..updatedAt = DateTime.now();
    await _envelopes.put(envelope);
  }

  Future<void> _maybePostCycleFunding(
    BudgetEnvelope envelope,
    BudgetPeriodWindow window,
  ) async {
    if (!envelope.autoRepeat || envelope.fundingSplits.isEmpty) return;

    final last = envelope.lastFundingCycleStart;
    if (last != null &&
        last.year == window.start.year &&
        last.month == window.start.month &&
        last.day == window.start.day) {
      return;
    }

    // Only auto-post when a previous funding cycle was recorded (user opted in).
    if (last == null) return;

    await _postFundingIncome(envelope, window.start);
    envelope
      ..lastFundingCycleStart = window.start
      ..updatedAt = DateTime.now();
    await _envelopes.put(envelope);
  }

  Future<void> _postFundingIncome(
    BudgetEnvelope envelope,
    DateTime fundingDate,
  ) async {
    for (final split in envelope.fundingSplits) {
      if (split.amount < ValidationConstants.minAmount) continue;
      final result = await _incomes.create(
        IncomeInput(
          amount: split.amount,
          source: fundingIncomeSource,
          accountId: split.accountId,
          date: fundingDate,
          notes: 'Envelope funding',
        ),
      );
      if (!result.success) {
        throw ValidationException(
          message: result.userMessage ?? 'Could not record funding income',
          field: 'funding',
        );
      }
    }
  }

  List<EnvelopeFundingSplit> _mapFundingSplits(BudgetEnvelopeInput input) {
    return input.fundingSplits
        .map(
          (s) => EnvelopeFundingSplit()
            ..accountId = s.accountId
            ..amount = s.amount,
        )
        .toList();
  }

  Future<void> _assertNoConflict(
    int profileId,
    BudgetEnvelopeInput input, {
    int? excludeId,
  }) async {
    final existing = await _envelopes.findByProfile(profileId);
    for (final envelope in existing) {
      if (excludeId != null && envelope.id == excludeId) continue;

      if (envelope.autoRepeat || input.autoRepeat) {
        throw const ValidationException(
          message:
              'An auto-repeating envelope already exists. Turn off auto-repeat or delete it first.',
          code: 'ENVELOPE_EXISTS',
          field: 'period',
        );
      }

      if (BudgetPeriodUtils.rangesOverlap(
        envelope.periodStart,
        envelope.periodEnd,
        input.periodStart,
        input.periodEnd,
      )) {
        throw const ValidationException(
          message: 'An envelope already exists for that date range',
          code: 'ENVELOPE_EXISTS',
          field: 'period',
        );
      }
    }
  }

  Future<void> _validateInput(BudgetEnvelopeInput input, int profileId) async {
    if (input.totalAmount < ValidationConstants.minAmount ||
        input.totalAmount > ValidationConstants.maxAmount) {
      throw const ValidationException(
        message: 'Enter a valid envelope total',
        field: 'totalAmount',
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
    if (input.fundingSplits.isEmpty) {
      throw const ValidationException(
        message: 'Add at least one funding split',
        field: 'funding',
      );
    }

    final accountIds = <int>{};
    var fundingSum = 0.0;
    for (final split in input.fundingSplits) {
      if (!accountIds.add(split.accountId)) {
        throw const ValidationException(
          message: 'Each account can only appear once in funding',
          field: 'funding',
        );
      }
      if (split.amount < ValidationConstants.minAmount ||
          split.amount > ValidationConstants.maxAmount) {
        throw const ValidationException(
          message: 'Enter a valid funding amount',
          field: 'funding',
        );
      }
      final account = await _accounts.findById(split.accountId);
      if (account == null ||
          account.profileId != profileId ||
          account.isArchived) {
        throw const NotFoundException(message: 'Payment account not found');
      }
      fundingSum += split.amount;
    }

    if ((fundingSum - input.totalAmount).abs() > _amountEpsilon) {
      throw ValidationException(
        message:
            'Funding splits must sum to ${input.totalAmount.toStringAsFixed(2)}',
        field: 'funding',
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

  Future<BudgetEnvelope> _getOwned(int id, int profileId) async {
    final envelope = await _envelopes.getOrThrow(id);
    if (envelope.profileId != profileId) {
      throw const NotFoundException(message: 'Envelope not found');
    }
    return envelope;
  }
}
