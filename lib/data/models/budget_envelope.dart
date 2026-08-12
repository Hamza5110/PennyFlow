import 'package:isar_community/isar.dart';

import '../../core/constants/app_constants.dart';

part 'budget_envelope.g.dart';

@collection
class BudgetEnvelope {
  Id id = Isar.autoIncrement;

  late double totalAmount;

  /// [BudgetPeriodType] name: monthly | days7 | days15 | months3 | custom.
  String periodType = 'days7';

  DateTime periodStart = DateTime.now();

  DateTime periodEnd = DateTime.now();

  bool autoRepeat = true;

  double warningThreshold = AppConstants.defaultBudgetWarningThreshold;

  bool warningNotified = false;

  bool exceededNotified = false;

  /// Start of the cycle for which notification flags currently apply.
  DateTime? lastCycleStart;

  /// Start of the cycle for which funding income was last posted.
  DateTime? lastFundingCycleStart;

  /// Legacy field — envelopes no longer pre-allocate by category.
  /// Kept empty for schema/backup compatibility.
  List<EnvelopeCategoryAllocation> categoryAllocations = [];

  List<EnvelopeFundingSplit> fundingSplits = [];

  @Index()
  late int profileId;

  DateTime createdAt = DateTime.now();

  DateTime updatedAt = DateTime.now();
}

@embedded
class EnvelopeCategoryAllocation {
  late int categoryId;
  late double amount;
}

@embedded
class EnvelopeFundingSplit {
  late int accountId;
  late double amount;
}
