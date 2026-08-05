import 'package:equatable/equatable.dart';

class StatisticsSummary extends Equatable {
  const StatisticsSummary({
    required this.totalIncome,
    required this.totalExpense,
    required this.savings,
    required this.averageDailySpending,
    this.largestExpenseAmount,
    this.largestExpenseLabel,
  });

  final double totalIncome;
  final double totalExpense;
  final double savings;
  final double averageDailySpending;
  final double? largestExpenseAmount;
  final String? largestExpenseLabel;

  @override
  List<Object?> get props => [
        totalIncome,
        totalExpense,
        savings,
        averageDailySpending,
        largestExpenseAmount,
        largestExpenseLabel,
      ];
}
