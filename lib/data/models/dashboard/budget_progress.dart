import 'package:equatable/equatable.dart';

/// Budget progress row for dashboard (FR-006).
class BudgetProgress extends Equatable {
  const BudgetProgress({
    required this.budgetId,
    required this.categoryName,
    required this.colorHex,
    required this.spent,
    required this.target,
    this.warningThreshold = 0.8,
  });

  final int budgetId;
  final String categoryName;
  final String colorHex;
  final double spent;
  final double target;
  final double warningThreshold;

  double get ratio => target <= 0 ? 0 : spent / target;

  double get remaining => (target - spent).clamp(0, double.infinity);

  @override
  List<Object?> get props =>
      [budgetId, categoryName, colorHex, spent, target, warningThreshold];
}
