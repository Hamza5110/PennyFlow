import 'package:equatable/equatable.dart';

class BudgetInput extends Equatable {
  const BudgetInput({
    required this.categoryId,
    required this.targetAmount,
    required this.year,
    required this.month,
    this.warningThreshold = 0.8,
  });

  final int categoryId;
  final double targetAmount;
  final int year;
  final int month;
  final double warningThreshold;

  @override
  List<Object?> get props =>
      [categoryId, targetAmount, year, month, warningThreshold];
}
