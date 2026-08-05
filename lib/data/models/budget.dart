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

  /// Calendar month 1–12.
  @Index()
  late int month;

  double warningThreshold = AppConstants.defaultBudgetWarningThreshold;

  bool warningNotified = false;

  bool exceededNotified = false;

  @Index()
  late int profileId;

  DateTime createdAt = DateTime.now();

  DateTime updatedAt = DateTime.now();
}
