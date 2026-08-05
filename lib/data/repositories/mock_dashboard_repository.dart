import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../core/base/base_repository.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/app_date_utils.dart';
import '../models/dashboard/dashboard_period.dart';
import '../models/dashboard/dashboard_summary.dart';
import '../models/dashboard/mock_budget_progress.dart';
import '../models/dashboard/mock_quick_add_option.dart';
import '../models/dashboard/mock_transaction.dart';
import '../models/dashboard/monthly_spending_point.dart';

/// In-memory dashboard data source for Phase 3 (IMPLEMENTATION_PLAN §Phase 3).
///
/// Replaced by real repositories when expense/income modules land in Phase 4+.
class MockDashboardRepository extends BaseRepository {
  MockDashboardRepository({DateTime? referenceNow})
      : _now = referenceNow ?? DateTime.now() {
    _seed();
  }

  final DateTime _now;
  final _uuid = const Uuid();
  final List<MockTransaction> _transactions = [];
  final List<MockBudgetProgress> _budgets = [];
  final List<MockQuickAddCategory> _categories = [];
  final List<MockQuickAddAccount> _accounts = [];

  // Static friend-ledger mock totals (FR-002).
  static const double _moneyLent = 15000;
  static const double _moneyBorrowed = 5000;
  static const double _pendingReceive = 8500;
  static const double _pendingPay = 2000;

  List<MockQuickAddCategory> get quickAddCategories =>
      List.unmodifiable(_categories);

  List<MockQuickAddAccount> get quickAddAccounts => List.unmodifiable(_accounts);

  DashboardSummary getSummary(DashboardPeriod period) {
    final range = period.toDateRange(now: _now);
    final expenses = _transactions.where(
      (t) => t.isExpense && range.contains(t.date),
    );
    final incomes = _transactions.where(
      (t) => !t.isExpense && range.contains(t.date),
    );

    final totalExpense =
        expenses.fold<double>(0, (sum, t) => sum + t.amount);
    final totalIncome = incomes.fold<double>(0, (sum, t) => sum + t.amount);

    final todayRange = AppDateUtils.rangeFor(DatePeriod.today, now: _now);
    final monthRange = AppDateUtils.rangeFor(DatePeriod.thisMonth, now: _now);

    final todaySpending = _transactions
        .where((t) => t.isExpense && todayRange.contains(t.date))
        .fold<double>(0, (sum, t) => sum + t.amount);

    final monthSpending = _transactions
        .where((t) => t.isExpense && monthRange.contains(t.date))
        .fold<double>(0, (sum, t) => sum + t.amount);

    return DashboardSummary(
      totalExpense: totalExpense,
      totalIncome: totalIncome,
      balance: totalIncome - totalExpense,
      moneyLent: _moneyLent,
      moneyBorrowed: _moneyBorrowed,
      pendingReceive: _pendingReceive,
      pendingPay: _pendingPay,
      todaySpending: todaySpending,
      monthSpending: monthSpending,
    );
  }

  List<MockTransaction> getRecentTransactions({
    int limit = AppConstants.defaultRecentTransactionCount,
  }) {
    final sorted = [..._transactions]
      ..sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(limit).toList();
  }

  List<MonthlySpendingPoint> getMonthlySpending({int months = 6}) {
    final formatter = DateFormat('MMM');
    final points = <MonthlySpendingPoint>[];

    for (var i = months - 1; i >= 0; i--) {
      final monthDate = DateTime(_now.year, _now.month - i, 1);
      final start = DateTime(monthDate.year, monthDate.month);
      final end = DateTime(monthDate.year, monthDate.month + 1, 0, 23, 59, 59);
      final total = _transactions
          .where(
            (t) =>
                t.isExpense &&
                !t.date.isBefore(start) &&
                !t.date.isAfter(end),
          )
          .fold<double>(0, (sum, t) => sum + t.amount);

      points.add(
        MonthlySpendingPoint(
          month: start,
          label: formatter.format(start),
          amount: total,
        ),
      );
    }
    return points;
  }

  List<MockBudgetProgress> getBudgetProgress() =>
      List.unmodifiable(_budgets);

  MockTransaction addQuickExpense({
    required double amount,
    required String categoryId,
    required String accountId,
  }) {
    final category = _categories.firstWhere((c) => c.id == categoryId);
    final account = _accounts.firstWhere((a) => a.id == accountId);

    final transaction = MockTransaction(
      id: _uuid.v4(),
      type: MockTransactionType.expense,
      amount: amount,
      title: category.name,
      categoryName: category.name,
      categoryColorHex: category.colorHex,
      accountName: account.name,
      date: _now,
    );

    _transactions.insert(0, transaction);
    _applyExpenseToBudget(category.name, amount);
    return transaction;
  }

  void _applyExpenseToBudget(String categoryName, double amount) {
    final index = _budgets.indexWhere((b) => b.categoryName == categoryName);
    if (index == -1) return;
    final budget = _budgets[index];
    _budgets[index] = MockBudgetProgress(
      categoryName: budget.categoryName,
      colorHex: budget.colorHex,
      spent: budget.spent + amount,
      target: budget.target,
      warningThreshold: budget.warningThreshold,
    );
  }

  void _seed() {
    _categories.addAll(const [
      MockQuickAddCategory(id: 'food', name: 'Food', colorHex: '#F97316'),
      MockQuickAddCategory(id: 'fuel', name: 'Fuel', colorHex: '#EAB308'),
      MockQuickAddCategory(
        id: 'grocery',
        name: 'Grocery',
        colorHex: '#22C55E',
      ),
      MockQuickAddCategory(id: 'bills', name: 'Bills', colorHex: '#3B82F6'),
    ]);

    _accounts.addAll(const [
      MockQuickAddAccount(id: 'cash', name: 'Cash'),
      MockQuickAddAccount(id: 'bank', name: 'Bank Account'),
      MockQuickAddAccount(id: 'easypaisa', name: 'EasyPaisa'),
    ]);

    _budgets.addAll(const [
      MockBudgetProgress(
        categoryName: 'Food',
        colorHex: '#F97316',
        spent: 8200,
        target: 12000,
      ),
      MockBudgetProgress(
        categoryName: 'Grocery',
        colorHex: '#22C55E',
        spent: 10500,
        target: 10000,
      ),
      MockBudgetProgress(
        categoryName: 'Fuel',
        colorHex: '#EAB308',
        spent: 4500,
        target: 8000,
      ),
    ]);

    _transactions.addAll([
      MockTransaction(
        id: 't1',
        type: MockTransactionType.expense,
        amount: 450,
        title: 'Breakfast',
        categoryName: 'Food',
        categoryColorHex: '#F97316',
        accountName: 'Cash',
        date: _now.subtract(const Duration(hours: 2)),
      ),
      MockTransaction(
        id: 't2',
        type: MockTransactionType.expense,
        amount: 3200,
        title: 'Grocery run',
        categoryName: 'Grocery',
        categoryColorHex: '#22C55E',
        accountName: 'Bank Account',
        date: _now.subtract(const Duration(days: 1)),
      ),
      MockTransaction(
        id: 't3',
        type: MockTransactionType.income,
        amount: 85000,
        title: 'Salary',
        categoryName: 'Income',
        categoryColorHex: '#059669',
        accountName: 'Bank Account',
        date: _now.subtract(const Duration(days: 3)),
      ),
      MockTransaction(
        id: 't4',
        type: MockTransactionType.expense,
        amount: 2500,
        title: 'Fuel refill',
        categoryName: 'Fuel',
        categoryColorHex: '#EAB308',
        accountName: 'EasyPaisa',
        date: _now.subtract(const Duration(days: 2)),
      ),
      MockTransaction(
        id: 't5',
        type: MockTransactionType.expense,
        amount: 1800,
        title: 'Electricity bill',
        categoryName: 'Bills',
        categoryColorHex: '#3B82F6',
        accountName: 'Bank Account',
        date: _now.subtract(const Duration(days: 4)),
      ),
      MockTransaction(
        id: 't6',
        type: MockTransactionType.expense,
        amount: 650,
        title: 'Tea & snacks',
        categoryName: 'Food',
        categoryColorHex: '#F97316',
        accountName: 'Cash',
        date: _now.subtract(const Duration(days: 5)),
      ),
      MockTransaction(
        id: 't7',
        type: MockTransactionType.income,
        amount: 12000,
        title: 'Freelance',
        categoryName: 'Income',
        categoryColorHex: '#059669',
        accountName: 'Bank Account',
        date: _now.subtract(const Duration(days: 6)),
      ),
      MockTransaction(
        id: 't8',
        type: MockTransactionType.expense,
        amount: 900,
        title: 'Lunch',
        categoryName: 'Food',
        categoryColorHex: '#F97316',
        accountName: 'Cash',
        date: _now.subtract(const Duration(days: 7)),
      ),
    ]);

    // Spread historical expenses across prior months for the chart.
    for (var m = 1; m < 6; m++) {
      _transactions.add(
        MockTransaction(
          id: 'hist-$m',
          type: MockTransactionType.expense,
          amount: 12000 + (m * 850),
          title: 'Monthly spending',
          categoryName: 'Other',
          categoryColorHex: '#64748B',
          accountName: 'Bank Account',
          date: DateTime(_now.year, _now.month - m, 15),
        ),
      );
    }
  }
}
