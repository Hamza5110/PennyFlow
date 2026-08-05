import 'package:equatable/equatable.dart';

/// Aggregated dashboard figures (FR-001 – FR-003, FR-002).
class DashboardSummary extends Equatable {
  const DashboardSummary({
    required this.totalExpense,
    required this.totalIncome,
    required this.balance,
    required this.moneyLent,
    required this.moneyBorrowed,
    required this.pendingReceive,
    required this.pendingPay,
    required this.todaySpending,
    required this.monthSpending,
  });

  final double totalExpense;
  final double totalIncome;
  final double balance;
  final double moneyLent;
  final double moneyBorrowed;
  final double pendingReceive;
  final double pendingPay;
  final double todaySpending;
  final double monthSpending;

  @override
  List<Object?> get props => [
        totalExpense,
        totalIncome,
        balance,
        moneyLent,
        moneyBorrowed,
        pendingReceive,
        pendingPay,
        todaySpending,
        monthSpending,
      ];
}
