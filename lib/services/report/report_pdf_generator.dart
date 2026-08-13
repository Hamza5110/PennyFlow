import 'dart:io';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../core/utils/formatters.dart';
import '../../data/models/report/report_data.dart';

abstract final class ReportPdfGenerator {
  static Future<File> writeToFile({
    required ReportData data,
    required String path,
  }) async {
    final dateFmt = DateFormat('dd MMM yyyy');
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          pw.Text(
            'SpendVault Report',
            style: pw.TextStyle(
              fontSize: 22,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text('Profile: ${data.profileName}'),
          pw.Text(
            'Period: ${dateFmt.format(data.scope.from)} - ${dateFmt.format(data.scope.to)}',
          ),
          pw.SizedBox(height: 16),
          pw.Text('Summary', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          _summaryTable(data),
          if (data.scope.includeIncome && data.incomes.isNotEmpty) ...[
            pw.SizedBox(height: 20),
            pw.Text('Income', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            _incomeTable(data, dateFmt),
          ],
          if (data.scope.includeExpenses && data.expenses.isNotEmpty) ...[
            pw.SizedBox(height: 20),
            pw.Text('Expenses', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            _expenseTable(data, dateFmt),
          ],
          if (data.scope.includeFriends) ...[
            pw.SizedBox(height: 20),
            pw.Text(
              'Friend Balances',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            _friendSummaryTable(data),
            if (data.friendTransactions.isNotEmpty) ...[
              pw.SizedBox(height: 12),
              _friendTransactionsTable(data, dateFmt),
            ],
          ],
          if (data.scope.includeCategorySummary &&
              data.categoryBreakdown.isNotEmpty) ...[
            pw.SizedBox(height: 20),
            pw.Text(
              'Category Summary',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            _categoryTable(data),
          ],
          if (data.scope.includeMonthlySummary &&
              data.monthlySummary.isNotEmpty) ...[
            pw.SizedBox(height: 20),
            pw.Text(
              'Monthly Summary',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            _monthlyTable(data),
          ],
        ],
      ),
    );

    final file = File(path);
    await file.writeAsBytes(await doc.save());
    return file;
  }

  static pw.Widget _summaryTable(ReportData data) {
    return pw.TableHelper.fromTextArray(
      headers: ['Metric', 'Amount'],
      data: [
        ['Total Income', _money(data.totalIncome, data.currencyCode)],
        ['Total Expense', _money(data.totalExpense, data.currencyCode)],
        ['Net Savings', _money(data.netSavings, data.currencyCode)],
      ],
    );
  }

  static pw.Widget _incomeTable(ReportData data, DateFormat dateFmt) {
    return pw.TableHelper.fromTextArray(
      headers: ['Date', 'Source', 'Account', 'Amount'],
      data: [
        for (final row in data.incomes)
          [
            dateFmt.format(row.date),
            row.source,
            row.accountName,
            _money(row.amount, data.currencyCode),
          ],
      ],
    );
  }

  static pw.Widget _expenseTable(ReportData data, DateFormat dateFmt) {
    return pw.TableHelper.fromTextArray(
      headers: ['Date', 'Category', 'Account', 'Amount'],
      data: [
        for (final row in data.expenses)
          [
            dateFmt.format(row.date),
            row.categoryName,
            row.accountName,
            _money(row.amount, data.currencyCode),
          ],
      ],
    );
  }

  static pw.Widget _friendSummaryTable(ReportData data) {
    return pw.TableHelper.fromTextArray(
      headers: ['Metric', 'Amount'],
      data: [
        ['Money Lent', _money(data.friendSummary.moneyLent, data.currencyCode)],
        [
          'Money Borrowed',
          _money(data.friendSummary.moneyBorrowed, data.currencyCode),
        ],
        [
          'Pending Receive',
          _money(data.friendSummary.pendingReceive, data.currencyCode),
        ],
        ['Pending Pay', _money(data.friendSummary.pendingPay, data.currencyCode)],
      ],
    );
  }

  static pw.Widget _friendTransactionsTable(
    ReportData data,
    DateFormat dateFmt,
  ) {
    return pw.TableHelper.fromTextArray(
      headers: ['Date', 'Friend', 'Type', 'Amount', 'Status'],
      data: [
        for (final row in data.friendTransactions)
          [
            dateFmt.format(row.date),
            row.friendName,
            row.type,
            _money(row.amount, data.currencyCode),
            row.status,
          ],
      ],
    );
  }

  static pw.Widget _categoryTable(ReportData data) {
    return pw.TableHelper.fromTextArray(
      headers: ['Category', 'Amount', 'Share %'],
      data: [
        for (final item in data.categoryBreakdown)
          [
            item.name,
            _money(item.amount, data.currencyCode),
            '${(item.percentage * 100).toStringAsFixed(1)}%',
          ],
      ],
    );
  }

  static pw.Widget _monthlyTable(ReportData data) {
    return pw.TableHelper.fromTextArray(
      headers: ['Month', 'Income', 'Expense', 'Net'],
      data: [
        for (final row in data.monthlySummary)
          [
            row.monthLabel,
            _money(row.income, data.currencyCode),
            _money(row.expense, data.currencyCode),
            _money(row.net, data.currencyCode),
          ],
      ],
    );
  }

  static String _money(double amount, String currencyCode) =>
      AppFormatters.currency(amount, currencyCode: currencyCode);
}
