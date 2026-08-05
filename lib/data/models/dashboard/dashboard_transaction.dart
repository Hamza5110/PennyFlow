import 'package:equatable/equatable.dart';

enum DashboardTransactionKind { expense, income }

/// Unified expense/income row for dashboard recent activity (FR-004).
class DashboardTransaction extends Equatable {
  const DashboardTransaction({
    required this.kind,
    required this.recordId,
    required this.amount,
    required this.title,
    required this.subtitle,
    required this.colorHex,
    required this.accountName,
    required this.date,
  });

  final DashboardTransactionKind kind;
  final int recordId;
  final double amount;
  final String title;
  final String subtitle;
  final String colorHex;
  final String accountName;
  final DateTime date;

  bool get isExpense => kind == DashboardTransactionKind.expense;

  @override
  List<Object?> get props => [
        kind,
        recordId,
        amount,
        title,
        subtitle,
        colorHex,
        accountName,
        date,
      ];
}
