import 'package:equatable/equatable.dart';

import '../enums/app_enums.dart';

class BudgetInput extends Equatable {
  const BudgetInput({
    required this.categoryId,
    required this.targetAmount,
    required this.periodType,
    required this.periodStart,
    required this.periodEnd,
    this.autoRepeat = true,
    this.warningThreshold = 0.8,
  });

  final int categoryId;
  final double targetAmount;
  final BudgetPeriodType periodType;
  final DateTime periodStart;
  final DateTime periodEnd;
  final bool autoRepeat;
  final double warningThreshold;

  int get year => periodStart.year;
  int get month => periodStart.month;

  @override
  List<Object?> get props => [
        categoryId,
        targetAmount,
        periodType,
        periodStart,
        periodEnd,
        autoRepeat,
        warningThreshold,
      ];
}
