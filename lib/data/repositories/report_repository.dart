import 'package:intl/intl.dart';

import '../../core/base/base_repository.dart';
import '../../core/constants/friend_constants.dart';
import '../../core/extensions/date_extensions.dart';
import '../../core/utils/app_date_utils.dart';
import '../models/friend/friend_models.dart';
import '../models/report/report_data.dart';
import '../models/report/report_scope.dart';
import '../models/statistics/category_statistic.dart';
import 'category_repository.dart';
import 'expense_repository.dart';
import 'friend_repository.dart';
import 'friend_transaction_repository.dart';
import 'income_repository.dart';
import 'payment_account_repository.dart';
import 'profile_repository.dart';
import 'repayment_repository.dart';

/// Aggregates profile data for report export (FR-112).
class ReportRepository extends BaseRepository {
  ReportRepository(
    this._profiles,
    this._expenses,
    this._incomes,
    this._categories,
    this._accounts,
    this._friends,
    this._friendTransactions,
    this._repayments,
  );

  final ProfileRepository _profiles;
  final ExpenseRepository _expenses;
  final IncomeRepository _incomes;
  final CategoryRepository _categories;
  final PaymentAccountRepository _accounts;
  final FriendRepository _friends;
  final FriendTransactionRepository _friendTransactions;
  final RepaymentRepository _repayments;

  Future<ReportData> buildReportData({
    required int profileId,
    required ReportScope scope,
    required String currencyCode,
  }) async {
    final profile = await _profiles.findById(profileId);
    final range = scope.dateRange;

    final expenses = scope.includeExpenses
        ? await _loadExpenses(profileId, range)
        : <ReportExpenseRow>[];
    final incomes = scope.includeIncome
        ? await _loadIncomes(profileId, range)
        : <ReportIncomeRow>[];
    final friendTransactions = scope.includeFriends
        ? await _loadFriendTransactions(profileId, range)
        : <ReportFriendRow>[];
    final categoryBreakdown = scope.includeCategorySummary
        ? await _loadCategoryBreakdown(profileId, range)
        : <CategoryStatistic>[];
    final monthlySummary = scope.includeMonthlySummary
        ? await _loadMonthlySummary(profileId, scope)
        : <ReportMonthlySummaryRow>[];

    final totalExpense =
        expenses.fold<double>(0, (sum, row) => sum + row.amount);
    final totalIncome = incomes.fold<double>(0, (sum, row) => sum + row.amount);
    final friendSummary = scope.includeFriends
        ? await _friendSummaryForPeriod(profileId, range)
        : const FriendLedgerSummary(
            moneyLent: 0,
            moneyBorrowed: 0,
            pendingReceive: 0,
            pendingPay: 0,
          );

    return ReportData(
      profileName: profile?.name ?? 'Profile',
      currencyCode: currencyCode,
      scope: scope,
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      expenses: expenses,
      incomes: incomes,
      friendSummary: friendSummary,
      friendTransactions: friendTransactions,
      categoryBreakdown: categoryBreakdown,
      monthlySummary: monthlySummary,
    );
  }

  Future<List<ReportExpenseRow>> _loadExpenses(
    int profileId,
    DateRange range,
  ) async {
    final all = await _expenses.findActiveByProfile(profileId);
    final categories = await _categories.findByProfile(profileId);
    final accounts = await _accounts.findByProfile(profileId);
    final categoryMap = {for (final c in categories) c.id: c};
    final accountMap = {for (final a in accounts) a.id: a};

    final filtered = all.where((e) => range.contains(e.date)).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return filtered
        .map(
          (expense) => ReportExpenseRow(
            date: expense.date,
            categoryName:
                categoryMap[expense.categoryId]?.name ?? 'Unknown',
            accountName: accountMap[expense.accountId]?.name ?? 'Unknown',
            amount: expense.amount,
            notes: expense.notes,
          ),
        )
        .toList();
  }

  Future<List<ReportIncomeRow>> _loadIncomes(
    int profileId,
    DateRange range,
  ) async {
    final all = await _incomes.findActiveByProfile(profileId);
    final accounts = await _accounts.findByProfile(profileId);
    final accountMap = {for (final a in accounts) a.id: a};

    final filtered = all.where((i) => range.contains(i.date)).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return filtered
        .map(
          (income) => ReportIncomeRow(
            date: income.date,
            source: income.source,
            accountName: accountMap[income.accountId]?.name ?? 'Unknown',
            amount: income.amount,
            notes: income.notes,
          ),
        )
        .toList();
  }

  Future<List<ReportFriendRow>> _loadFriendTransactions(
    int profileId,
    DateRange range,
  ) async {
    final transactions =
        await _friendTransactions.findActiveByProfile(profileId);
    final friends = await _friends.findByProfile(profileId);
    final friendMap = {for (final f in friends) f.id: f};

    final filtered = transactions.where((t) => range.contains(t.date)).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return filtered
        .map(
          (txn) => ReportFriendRow(
            date: txn.date,
            friendName: friendMap[txn.friendId]?.name ?? 'Unknown',
            type: txn.type,
            amount: txn.amount,
            status: txn.status,
            notes: txn.notes,
          ),
        )
        .toList();
  }

  Future<FriendLedgerSummary> _friendSummaryForPeriod(
    int profileId,
    DateRange range,
  ) async {
    final transactions =
        await _friendTransactions.findActiveByProfile(profileId);
    final inPeriod =
        transactions.where((t) => range.contains(t.date)).toList();

    var moneyLent = 0.0;
    var moneyBorrowed = 0.0;
    var pendingReceive = 0.0;
    var pendingPay = 0.0;

    for (final txn in inPeriod) {
      final remaining = await _remainingBalance(txn.id);
      if (txn.type == FriendTransactionTypes.given) {
        moneyLent += txn.amount;
        pendingReceive += remaining;
      } else {
        moneyBorrowed += txn.amount;
        pendingPay += remaining;
      }
    }

    return FriendLedgerSummary(
      moneyLent: moneyLent,
      moneyBorrowed: moneyBorrowed,
      pendingReceive: pendingReceive,
      pendingPay: pendingPay,
    );
  }

  Future<double> _remainingBalance(int transactionId) async {
    final txn = await _friendTransactions.findById(transactionId);
    if (txn == null) return 0;

    final repayments = await _repayments.findByTransaction(transactionId);
    final paid = repayments.fold<double>(0, (sum, r) => sum + r.amount);
    final remaining = txn.amount - paid;
    return remaining > 0 ? remaining : 0;
  }

  Future<List<CategoryStatistic>> _loadCategoryBreakdown(
    int profileId,
    DateRange range,
  ) async {
    final expenses = await _expenses.findActiveByProfile(profileId);
    final categories = await _categories.findByProfile(profileId);
    final categoryMap = {for (final c in categories) c.id: c};

    final totals = <int, double>{};
    for (final expense in expenses) {
      if (!range.contains(expense.date)) continue;
      totals[expense.categoryId] =
          (totals[expense.categoryId] ?? 0) + expense.amount;
    }

    final grandTotal = totals.values.fold<double>(0, (sum, v) => sum + v);
    if (grandTotal <= 0) return [];

    final stats = totals.entries.map((entry) {
      final category = categoryMap[entry.key];
      return CategoryStatistic(
        categoryId: entry.key,
        name: category?.name ?? 'Unknown',
        colorHex: category?.colorHex ?? '#64748B',
        amount: entry.value,
        percentage: entry.value / grandTotal,
      );
    }).toList();

    stats.sort((a, b) => b.amount.compareTo(a.amount));
    return stats;
  }

  Future<List<ReportMonthlySummaryRow>> _loadMonthlySummary(
    int profileId,
    ReportScope scope,
  ) async {
    final formatter = DateFormat('MMM yyyy');
    final expenses = await _expenses.findActiveByProfile(profileId);
    final incomes = await _incomes.findActiveByProfile(profileId);
    final rows = <ReportMonthlySummaryRow>[];

    var cursor = DateTime(scope.from.year, scope.from.month).startOfMonth;
    final endMonth = DateTime(scope.to.year, scope.to.month).startOfMonth;

    while (!cursor.isAfter(endMonth)) {
      final monthStart = cursor.startOfMonth;
      final monthEnd = cursor.endOfMonth;
      final incomeTotal = incomes
          .where((i) => i.date.isBetween(monthStart, monthEnd))
          .fold<double>(0, (sum, i) => sum + i.amount);
      final expenseTotal = expenses
          .where((e) => e.date.isBetween(monthStart, monthEnd))
          .fold<double>(0, (sum, e) => sum + e.amount);

      rows.add(
        ReportMonthlySummaryRow(
          monthLabel: formatter.format(monthStart),
          income: incomeTotal,
          expense: expenseTotal,
          net: incomeTotal - expenseTotal,
        ),
      );

      cursor = DateTime(cursor.year, cursor.month + 1);
    }

    return rows;
  }
}
