import 'dart:io';

import 'package:excel/excel.dart';
import 'package:intl/intl.dart';

import '../../core/utils/formatters.dart';
import '../../data/models/report/report_data.dart';

abstract final class ReportExcelGenerator {
  static Future<File> writeToFile({
    required ReportData data,
    required String path,
  }) async {
    final excel = Excel.createExcel();
    final dateFmt = DateFormat('dd MMM yyyy');

    _writeSummarySheet(excel, data, dateFmt);
    if (data.scope.includeIncome) {
      _writeIncomeSheet(excel, data, dateFmt);
    }
    if (data.scope.includeExpenses) {
      _writeExpenseSheet(excel, data, dateFmt);
    }
    if (data.scope.includeFriends) {
      _writeFriendsSheet(excel, data, dateFmt);
    }
    if (data.scope.includeCategorySummary) {
      _writeCategorySheet(excel, data);
    }
    if (data.scope.includeMonthlySummary) {
      _writeMonthlySheet(excel, data);
    }

    excel.delete('Sheet1');
    final bytes = excel.encode();
    final file = File(path);
    await file.writeAsBytes(bytes!, flush: true);
    return file;
  }

  static void _writeSummarySheet(
    Excel excel,
    ReportData data,
    DateFormat dateFmt,
  ) {
    final sheet = excel['Summary'];
    _row(sheet, 0, ['SpendVault Report']);
    _row(sheet, 1, ['Profile', data.profileName]);
    _row(sheet, 2, [
      'Period',
      '${dateFmt.format(data.scope.from)} - ${dateFmt.format(data.scope.to)}',
    ]);
    _row(sheet, 4, ['Total Income', data.totalIncome]);
    _row(sheet, 5, ['Total Expense', data.totalExpense]);
    _row(sheet, 6, ['Net Savings', data.netSavings]);
  }

  static void _writeIncomeSheet(
    Excel excel,
    ReportData data,
    DateFormat dateFmt,
  ) {
    final sheet = excel['Income'];
    _row(sheet, 0, ['Date', 'Source', 'Account', 'Amount', 'Notes']);
    for (var i = 0; i < data.incomes.length; i++) {
      final row = data.incomes[i];
      _row(sheet, i + 1, [
        dateFmt.format(row.date),
        row.source,
        row.accountName,
        row.amount,
        row.notes ?? '',
      ]);
    }
  }

  static void _writeExpenseSheet(
    Excel excel,
    ReportData data,
    DateFormat dateFmt,
  ) {
    final sheet = excel['Expenses'];
    _row(sheet, 0, ['Date', 'Category', 'Account', 'Amount', 'Notes']);
    for (var i = 0; i < data.expenses.length; i++) {
      final row = data.expenses[i];
      _row(sheet, i + 1, [
        dateFmt.format(row.date),
        row.categoryName,
        row.accountName,
        row.amount,
        row.notes ?? '',
      ]);
    }
  }

  static void _writeFriendsSheet(
    Excel excel,
    ReportData data,
    DateFormat dateFmt,
  ) {
    final sheet = excel['Friends'];
    _row(sheet, 0, ['Money Lent', data.friendSummary.moneyLent]);
    _row(sheet, 1, ['Money Borrowed', data.friendSummary.moneyBorrowed]);
    _row(sheet, 2, ['Pending Receive', data.friendSummary.pendingReceive]);
    _row(sheet, 3, ['Pending Pay', data.friendSummary.pendingPay]);
    _row(sheet, 5, ['Date', 'Friend', 'Type', 'Amount', 'Status', 'Notes']);
    for (var i = 0; i < data.friendTransactions.length; i++) {
      final row = data.friendTransactions[i];
      _row(sheet, i + 6, [
        dateFmt.format(row.date),
        row.friendName,
        row.type,
        row.amount,
        row.status,
        row.notes ?? '',
      ]);
    }
  }

  static void _writeCategorySheet(Excel excel, ReportData data) {
    final sheet = excel['Categories'];
    _row(sheet, 0, ['Category', 'Amount', 'Share %']);
    for (var i = 0; i < data.categoryBreakdown.length; i++) {
      final item = data.categoryBreakdown[i];
      _row(sheet, i + 1, [
        item.name,
        item.amount,
        (item.percentage * 100).toStringAsFixed(1),
      ]);
    }
  }

  static void _writeMonthlySheet(Excel excel, ReportData data) {
    final sheet = excel['Monthly'];
    _row(sheet, 0, ['Month', 'Income', 'Expense', 'Net']);
    for (var i = 0; i < data.monthlySummary.length; i++) {
      final row = data.monthlySummary[i];
      _row(sheet, i + 1, [row.monthLabel, row.income, row.expense, row.net]);
    }
  }

  static void _row(Sheet sheet, int rowIndex, List<dynamic> values) {
    for (var col = 0; col < values.length; col++) {
      final cell = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: col, rowIndex: rowIndex),
      );
      final value = values[col];
      if (value is num) {
        cell.value = DoubleCellValue(value.toDouble());
      } else {
        cell.value = TextCellValue(value.toString());
      }
    }
  }

  static String money(double amount, String currencyCode) =>
      AppFormatters.currency(amount, currencyCode: currencyCode);
}
