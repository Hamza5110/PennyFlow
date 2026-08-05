import 'package:equatable/equatable.dart';

class StatisticsChartPoint extends Equatable {
  const StatisticsChartPoint({
    required this.label,
    required this.amount,
    this.secondaryAmount = 0,
    this.date,
  });

  final String label;
  final double amount;
  final double secondaryAmount;
  final DateTime? date;

  @override
  List<Object?> get props => [label, amount, secondaryAmount, date];
}
