import 'package:intl/intl.dart';

import '../../core/base/base_repository.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/income_sources.dart';
import '../../core/utils/app_date_utils.dart';
import '../models/dashboard/dashboard_period.dart';
import '../models/dashboard/dashboard_summary.dart';
import '../models/dashboard/dashboard_transaction.dart';
import '../models/dashboard/mock_budget_progress.dart';
import '../models/dashboard/monthly_spending_point.dart';
import '../../services/friend/friend_service.dart';
import 'category_repository.dart';
import 'expense_repository.dart';
import 'income_repository.dart';
import 'payment_account_repository.dart';

/// Aggregates real expense/income data for the dashboard (Phase 5).
class DashboardRepository extends BaseRepository {
  DashboardRepository(
    this._expenses,
    this._incomes,
    this._categories,
    this._accounts,
    this._friends,
  );

  final ExpenseRepository _expenses;
  final IncomeRepository _incomes;
  final CategoryRepository _categories;
  final PaymentAccountRepository _accounts;
  final FriendService _friends;

  Future<DashboardSummary> getSummary(
    int profileId,
    DashboardPeriod period, {
    DateTime? now,
  }) async {
    final reference = now ?? DateTime.now();
    final range = period.toDateRange(now: reference);

    final expenses = await _expenses.findActiveByProfile(profileId);
    final incomes = await _incomes.findActiveByProfile(profileId);

    final totalExpense = expenses
        .where((e) => range.contains(e.date))
        .fold<double>(0, (sum, e) => sum + e.amount);
    final totalIncome = incomes
        .where((e) => range.contains(e.date))
        .fold<double>(0, (sum, e) => sum + e.amount);

    final todayRange = AppDateUtils.rangeFor(DatePeriod.today, now: reference);
    final monthRange = AppDateUtils.rangeFor(DatePeriod.thisMonth, now: reference);

    final todaySpending = expenses
        .where((e) => todayRange.contains(e.date))
        .fold<double>(0, (sum, e) => sum + e.amount);

    final monthSpending = expenses
        .where((e) => monthRange.contains(e.date))
        .fold<double>(0, (sum, e) => sum + e.amount);

    final ledger = await _friends.getLedgerSummary();

    return DashboardSummary(
      totalExpense: totalExpense,
      totalIncome: totalIncome,
      balance: totalIncome - totalExpense,
      moneyLent: ledger.moneyLent,
      moneyBorrowed: ledger.moneyBorrowed,
      pendingReceive: ledger.pendingReceive,
      pendingPay: ledger.pendingPay,
      todaySpending: todaySpending,
      monthSpending: monthSpending,
    );
  }

  Future<List<DashboardTransaction>> getRecentTransactions(
    int profileId, {
    int limit = AppConstants.defaultRecentTransactionCount,
  }) async {
    final categories = await _categories.findByProfile(profileId);
    final accounts = await _accounts.findActiveByProfile(profileId);
    final categoryMap = {for (final c in categories) c.id: c};
    final accountMap = {for (final a in accounts) a.id: a};

    final expenses = await _expenses.findActiveByProfile(profileId);
    final incomes = await _incomes.findActiveByProfile(profileId);

    final items = <DashboardTransaction>[
      for (final expense in expenses)
        DashboardTransaction(
          kind: DashboardTransactionKind.expense,
          recordId: expense.id,
          amount: expense.amount,
          title: expense.notes?.isNotEmpty == true
              ? expense.notes!
              : (categoryMap[expense.categoryId]?.name ?? 'Expense'),
          subtitle: categoryMap[expense.categoryId]?.name ?? 'Expense',
          colorHex: categoryMap[expense.categoryId]?.colorHex ?? '#64748B',
          accountName: accountMap[expense.accountId]?.name ?? 'Unknown',
          date: expense.date,
        ),
      for (final income in incomes)
        DashboardTransaction(
          kind: DashboardTransactionKind.income,
          recordId: income.id,
          amount: income.amount,
          title: income.notes?.isNotEmpty == true
              ? income.notes!
              : income.source,
          subtitle: income.source,
          colorHex: IncomeSources.colorHexFor(
            IncomeSources.isPredefinedKey(income.source)
                ? income.source
                : IncomeSources.custom,
          ),
          accountName: accountMap[income.accountId]?.name ?? 'Unknown',
          date: income.date,
        ),
    ];

    items.sort((a, b) => b.date.compareTo(a.date));
    return items.take(limit).toList();
  }

  Future<List<MonthlySpendingPoint>> getMonthlySpending(
    int profileId, {
    int months = 6,
    DateTime? now,
  }) async {
    final reference = now ?? DateTime.now();
    final formatter = DateFormat('MMM');
    final expenses = await _expenses.findActiveByProfile(profileId);
    final points = <MonthlySpendingPoint>[];

    for (var i = months - 1; i >= 0; i--) {
      final monthDate = DateTime(reference.year, reference.month - i, 1);
      final start = DateTime(monthDate.year, monthDate.month);
      final end = DateTime(monthDate.year, monthDate.month + 1, 0, 23, 59, 59);
      final total = expenses
          .where(
            (e) => !e.date.isBefore(start) && !e.date.isAfter(end),
          )
          .fold<double>(0, (sum, e) => sum + e.amount);

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

  /// Budget progress remains mock until Phase 10.
  List<MockBudgetProgress> getBudgetProgress() => const [
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
      ];

}
