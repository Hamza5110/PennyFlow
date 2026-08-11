import 'package:isar_community/isar.dart';

import '../../core/constants/app_constants.dart';

part 'budget.g.dart';

@collection
class Budget {
  Id id = Isar.autoIncrement;

  @Index()
  late int categoryId;

  late double targetAmount;

  @Index()
  late int year;

  /// Calendar month 1–12 (kept in sync with [periodStart] for monthly budgets).
  @Index()
  late int month;

  /// [BudgetPeriodType] name: monthly | days7 | days15 | custom.
  String periodType = 'monthly';

  /// User-chosen period start (anchor for auto-repeat cycles).
  DateTime periodStart = DateTime.now();

  /// User-chosen period end for the template / fixed range.
  DateTime periodEnd = DateTime.now();

  /// When true, the budget rolls into the next period automatically.
  bool autoRepeat = true;

  /// Start of the cycle for which notification flags currently apply.
  DateTime? lastCycleStart;

  double warningThreshold = AppConstants.defaultBudgetWarningThreshold;

  bool warningNotified = false;

  bool exceededNotified = false;

  @Index()
  late int profileId;

  DateTime createdAt = DateTime.now();

  DateTime updatedAt = DateTime.now();
}
