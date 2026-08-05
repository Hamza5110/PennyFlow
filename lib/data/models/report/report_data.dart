import 'package:equatable/equatable.dart';

import '../friend/friend_models.dart';
import '../statistics/category_statistic.dart';
import 'report_scope.dart';

class ReportExpenseRow extends Equatable {
  const ReportExpenseRow({
    required this.date,
    required this.categoryName,
    required this.accountName,
    required this.amount,
    this.notes,
  });

  final DateTime date;
  final String categoryName;
  final String accountName;
  final double amount;
  final String? notes;

  @override
  List<Object?> get props => [date, categoryName, accountName, amount, notes];
}

class ReportIncomeRow extends Equatable {
  const ReportIncomeRow({
    required this.date,
    required this.source,
    required this.accountName,
    required this.amount,
    this.notes,
  });

  final DateTime date;
  final String source;
  final String accountName;
  final double amount;
  final String? notes;

  @override
  List<Object?> get props => [date, source, accountName, amount, notes];
}

class ReportFriendRow extends Equatable {
  const ReportFriendRow({
    required this.date,
    required this.friendName,
    required this.type,
    required this.amount,
    required this.status,
    this.notes,
  });

  final DateTime date;
  final String friendName;
  final String type;
  final double amount;
  final String status;
  final String? notes;

  @override
  List<Object?> get props =>
      [date, friendName, type, amount, status, notes];
}

class ReportMonthlySummaryRow extends Equatable {
  const ReportMonthlySummaryRow({
    required this.monthLabel,
    required this.income,
    required this.expense,
    required this.net,
  });

  final String monthLabel;
  final double income;
  final double expense;
  final double net;

  @override
  List<Object?> get props => [monthLabel, income, expense, net];
}

/// Aggregated report payload consumed by export generators (FR-112).
class ReportData extends Equatable {
  const ReportData({
    required this.profileName,
    required this.currencyCode,
    required this.scope,
    required this.totalIncome,
    required this.totalExpense,
    required this.expenses,
    required this.incomes,
    required this.friendSummary,
    required this.friendTransactions,
    required this.categoryBreakdown,
    required this.monthlySummary,
  });

  final String profileName;
  final String currencyCode;
  final ReportScope scope;
  final double totalIncome;
  final double totalExpense;
  final List<ReportExpenseRow> expenses;
  final List<ReportIncomeRow> incomes;
  final FriendLedgerSummary friendSummary;
  final List<ReportFriendRow> friendTransactions;
  final List<CategoryStatistic> categoryBreakdown;
  final List<ReportMonthlySummaryRow> monthlySummary;

  double get netSavings => totalIncome - totalExpense;

  @override
  List<Object?> get props => [
        profileName,
        currencyCode,
        scope,
        totalIncome,
        totalExpense,
        expenses,
        incomes,
        friendSummary,
        friendTransactions,
        categoryBreakdown,
        monthlySummary,
      ];
}

class ReportGeneratedFile extends Equatable {
  const ReportGeneratedFile({
    required this.path,
    required this.fileName,
    required this.format,
  });

  final String path;
  final String fileName;
  final ReportFormat format;

  @override
  List<Object?> get props => [path, fileName, format];
}
