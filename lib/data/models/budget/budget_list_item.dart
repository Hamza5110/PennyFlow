import 'package:equatable/equatable.dart';

import '../../../core/utils/budget_period_utils.dart';
import '../budget.dart';

/// Budget with computed spent/remaining for list and dashboard (FR-080).
class BudgetListItem extends Equatable {
  const BudgetListItem({
    required this.budget,
    required this.categoryName,
    required this.categoryColorHex,
    required this.spent,
    required this.window,
  });

  final Budget budget;
  final String categoryName;
  final String categoryColorHex;
  final double spent;
  final BudgetPeriodWindow window;

  double get target => budget.targetAmount;

  double get remaining => (target - spent).clamp(0, double.infinity);

  double get ratio => target <= 0 ? 0 : spent / target;

  @override
  List<Object?> get props =>
      [budget, categoryName, categoryColorHex, spent, window];
}
