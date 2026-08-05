import 'dart:io';

import 'package:csv/csv.dart';
import 'package:intl/intl.dart';

import '../../core/utils/formatters.dart';
import '../../data/models/report/report_data.dart';

abstract final class ReportCsvGenerator {
  static String generate(ReportData data) {
    final dateFmt = DateFormat('dd MMM yyyy');
    final rows = <List<dynamic>>[];

    rows.add(['PennyFlow Report']);
    rows.add(['Profile', data.profileName]);
    rows.add([
      'Period',
      '${dateFmt.format(data.scope.from)} - ${dateFmt.format(data.scope.to)}',
    ]);
    rows.add([]);

    rows.add(['Summary']);
    rows.add([
      'Total Income',
      _money(data.totalIncome, data.currencyCode),
    ]);
    rows.add([
      'Total Expense',
      _money(data.totalExpense, data.currencyCode),
    ]);
    rows.add([
      'Net Savings',
      _money(data.netSavings, data.currencyCode),
    ]);
    rows.add([]);

    if (data.scope.includeIncome && data.incomes.isNotEmpty) {
      rows.add(['Income']);
      rows.add(['Date', 'Source', 'Account', 'Amount', 'Notes']);
      for (final row in data.incomes) {
        rows.add([
          dateFmt.format(row.date),
          row.source,
          row.accountName,
          row.amount,
          row.notes ?? '',
        ]);
      }
      rows.add([]);
    }

    if (data.scope.includeExpenses && data.expenses.isNotEmpty) {
      rows.add(['Expenses']);
      rows.add(['Date', 'Category', 'Account', 'Amount', 'Notes']);
      for (final row in data.expenses) {
        rows.add([
          dateFmt.format(row.date),
          row.categoryName,
          row.accountName,
          row.amount,
          row.notes ?? '',
        ]);
      }
      rows.add([]);
    }

    if (data.scope.includeFriends) {
      rows.add(['Friend Balances']);
      rows.add([
        'Money Lent',
        _money(data.friendSummary.moneyLent, data.currencyCode),
      ]);
      rows.add([
        'Money Borrowed',
        _money(data.friendSummary.moneyBorrowed, data.currencyCode),
      ]);
      rows.add([
        'Pending Receive',
        _money(data.friendSummary.pendingReceive, data.currencyCode),
      ]);
      rows.add([
        'Pending Pay',
        _money(data.friendSummary.pendingPay, data.currencyCode),
      ]);
      rows.add([]);

      if (data.friendTransactions.isNotEmpty) {
        rows.add(['Friend Transactions']);
        rows.add(['Date', 'Friend', 'Type', 'Amount', 'Status', 'Notes']);
        for (final row in data.friendTransactions) {
          rows.add([
            dateFmt.format(row.date),
            row.friendName,
            row.type,
            row.amount,
            row.status,
            row.notes ?? '',
          ]);
        }
        rows.add([]);
      }
    }

    if (data.scope.includeCategorySummary && data.categoryBreakdown.isNotEmpty) {
      rows.add(['Category Summary']);
      rows.add(['Category', 'Amount', 'Share %']);
      for (final item in data.categoryBreakdown) {
        rows.add([
          item.name,
          item.amount,
          (item.percentage * 100).toStringAsFixed(1),
        ]);
      }
      rows.add([]);
    }

    if (data.scope.includeMonthlySummary && data.monthlySummary.isNotEmpty) {
      rows.add(['Monthly Summary']);
      rows.add(['Month', 'Income', 'Expense', 'Net']);
      for (final row in data.monthlySummary) {
        rows.add([
          row.monthLabel,
          row.income,
          row.expense,
          row.net,
        ]);
      }
    }

    return const ListToCsvConverter().convert(rows);
  }

  static Future<File> writeToFile({
    required ReportData data,
    required String path,
  }) async {
    final content = generate(data);
    final file = File(path);
    await file.writeAsString(content);
    return file;
  }

  static String _money(double amount, String currencyCode) =>
      AppFormatters.currency(amount, currencyCode: currencyCode);
}
