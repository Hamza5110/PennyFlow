import 'package:equatable/equatable.dart';

/// Monthly bar-chart data point (FR-005).
class MonthlySpendingPoint extends Equatable {
  const MonthlySpendingPoint({
    required this.month,
    required this.label,
    required this.amount,
  });

  final DateTime month;
  final String label;
  final double amount;

  @override
  List<Object?> get props => [month, label, amount];
}
