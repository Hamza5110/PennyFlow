import 'package:intl/intl.dart';

import '../../core/base/base_repository.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/income_sources.dart';
import '../../core/utils/app_date_utils.dart';
import '../../services/budget/budget_service.dart';
import '../../services/friend/friend_service.dart';
import '../models/dashboard/budget_progress.dart';
import '../models/dashboard/dashboard_period.dart';
import '../models/dashboard/dashboard_summary.dart';
import '../models/dashboard/dashboard_transaction.dart';
import '../models/dashboard/monthly_spending_point.dart';
import 'category_repository.dart';
import 'expense_repository.dart';
import 'income_repository.dart';
import 'payment_account_repository.dart';

/// Aggregates real expense/income data for the dashboard (Phase 5 / 20).
class DashboardRepository extends BaseRepository {
  DashboardRepository(
    this._expenses,
    this._incomes,
    this._categories,
    this._accounts,
    this._friends,
    this._budgets,
  );

  final ExpenseRepository _expenses;
  final IncomeRepository _incomes;
  final CategoryRepository _categories;
  final PaymentAccountRepository _accounts;
  final FriendService _friends;
  final BudgetService _budgets;

  Future<DashboardSummary> getSummary(
    int profileId,
    DashboardPeriod period, {
    DateTime? now,
  }) async {
    final reference = now ?? DateTime.now();
    final range = period.toDateRange(now: reference);
    final todayRange = AppDateUtils.rangeFor(DatePeriod.today, now: reference);
    final monthRange = AppDateUtils.rangeFor(DatePeriod.thisMonth, now: reference);

    final windowStart = _earliest([
      range.start,
      todayRange.start,
      monthRange.start,
    ]);
    final windowEnd = _latest([
      range.end,
      todayRange.end,
      monthRange.end,
    ]);

    final expenses = await _expenses.findActiveInRange(
      profileId,
      windowStart,
      windowEnd,
    );
    final incomes = await _incomes.findActiveInRange(
      profileId,
      windowStart,
      windowEnd,
    );

    final totalExpense = expenses
        .where((e) => range.contains(e.date))
        .fold<double>(0, (sum, e) => sum + e.amount);
    final totalIncome = incomes
        .where((e) => range.contains(e.date))
        .fold<double>(0, (sum, e) => sum + e.amount);

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

    final expenses = await _expenses.findRecentByProfile(profileId, limit: limit);
    final incomes = await _incomes.findRecentByProfile(profileId, limit: limit);

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
    final start = DateTime(reference.year, reference.month - (months - 1), 1);
    final end = DateTime(reference.year, reference.month + 1, 0, 23, 59, 59);
    final expenses = await _expenses.findActiveInRange(profileId, start, end);
    final points = <MonthlySpendingPoint>[];

    for (var i = months - 1; i >= 0; i--) {
      final monthDate = DateTime(reference.year, reference.month - i, 1);
      final monthStart = DateTime(monthDate.year, monthDate.month);
      final monthEnd = DateTime(monthDate.year, monthDate.month + 1, 0, 23, 59, 59);
      final total = expenses
          .where(
            (e) => !e.date.isBefore(monthStart) && !e.date.isAfter(monthEnd),
          )
          .fold<double>(0, (sum, e) => sum + e.amount);

      points.add(
        MonthlySpendingPoint(
          month: monthStart,
          label: formatter.format(monthStart),
          amount: total,
        ),
      );
    }
    return points;
  }

  Future<List<BudgetProgress>> getBudgetProgress() => _budgets.getDashboardProgress();

  DateTime _earliest(List<DateTime> values) =>
      values.reduce((a, b) => a.isBefore(b) ? a : b);

  DateTime _latest(List<DateTime> values) =>
      values.reduce((a, b) => a.isAfter(b) ? a : b);
}
