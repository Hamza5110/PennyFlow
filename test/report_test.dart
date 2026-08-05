import 'package:flutter_test/flutter_test.dart';
import 'package:penny_flow/data/models/report/report_scope.dart';
import 'package:penny_flow/services/report/report_csv_generator.dart';
import 'package:penny_flow/data/models/report/report_data.dart';
import 'package:penny_flow/data/models/friend/friend_models.dart';

void main() {
  group('ReportScope', () {
    test('monthly covers full calendar month', () {
      final scope = ReportScope.monthly(year: 2026, month: 2);
      expect(scope.from, DateTime(2026, 2, 1));
      expect(scope.to, DateTime(2026, 2, 28, 23, 59, 59, 999));
      expect(scope.includeMonthlySummary, isFalse);
    });

    test('yearly covers full year with monthly summary', () {
      final scope = ReportScope.yearly(year: 2025);
      expect(scope.from, DateTime(2025, 1, 1));
      expect(scope.to, DateTime(2025, 12, 31, 23, 59, 59, 999));
      expect(scope.includeMonthlySummary, isTrue);
    });

    test('custom normalizes day boundaries', () {
      final scope = ReportScope.custom(
        from: DateTime(2026, 3, 10, 15, 30),
        to: DateTime(2026, 3, 20, 8, 0),
      );
      expect(scope.from, DateTime(2026, 3, 10));
      expect(scope.to, DateTime(2026, 3, 20, 23, 59, 59, 999));
    });

    test('extensionFor maps formats', () {
      expect(ReportScope.extensionFor(ReportFormat.pdf), 'pdf');
      expect(ReportScope.extensionFor(ReportFormat.excel), 'xlsx');
      expect(ReportScope.extensionFor(ReportFormat.csv), 'csv');
    });
  });

  group('ReportCsvGenerator', () {
    test('includes summary and expense rows', () {
      final data = ReportData(
        profileName: 'Ali',
        currencyCode: 'PKR',
        scope: ReportScope.monthly(year: 2026, month: 3),
        totalIncome: 1000,
        totalExpense: 400,
        expenses: [
          ReportExpenseRow(
            date: DateTime(2026, 3, 5),
            categoryName: 'Food',
            accountName: 'Cash',
            amount: 400,
            notes: 'Lunch',
          ),
        ],
        incomes: [
          ReportIncomeRow(
            date: DateTime(2026, 3, 1),
            source: 'Salary',
            accountName: 'Bank',
            amount: 1000,
          ),
        ],
        friendSummary: const FriendLedgerSummary(
          moneyLent: 0,
          moneyBorrowed: 0,
          pendingReceive: 0,
          pendingPay: 0,
        ),
        friendTransactions: const [],
        categoryBreakdown: const [],
        monthlySummary: const [],
      );

      final csv = ReportCsvGenerator.generate(data);
      expect(csv, contains('PennyFlow Report'));
      expect(csv, contains('Food'));
      expect(csv, contains('Salary'));
      expect(csv, contains('Total Income'));
    });
  });
}
