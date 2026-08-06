import 'package:intl/intl.dart';

import '../../core/base/base_repository.dart';
import '../../core/extensions/date_extensions.dart';
import '../../core/utils/app_date_utils.dart';
import '../models/expense.dart';
import '../models/income.dart';
import '../models/statistics/category_statistic.dart';
import '../models/statistics/statistics_bundle.dart';
import '../models/statistics/statistics_chart_point.dart';
import '../models/statistics/statistics_period.dart';
import '../models/statistics/statistics_summary.dart';
import 'category_repository.dart';
import 'expense_repository.dart';
import 'income_repository.dart';

/// Aggregates expense/income data for statistics charts (Phase 11 / 20).
class StatisticsRepository extends BaseRepository {
  StatisticsRepository(
    this._expenses,
    this._incomes,
    this._categories,
  );

  final ExpenseRepository _expenses;
  final IncomeRepository _incomes;
  final CategoryRepository _categories;

  /// Loads all chart data in one DB pass for the selected period.
  Future<StatisticsBundle> loadBundle(
    int profileId,
    StatisticsPeriod period, {
    DateTime? now,
    int months = 6,
  }) async {
    final range = period.toDateRange(now: now);
    final expenses = await _expenses.findActiveInRange(
      profileId,
      range.start,
      range.end,
    );
    final incomes = await _incomes.findActiveInRange(
      profileId,
      range.start,
      range.end,
    );

    final summary = await _buildSummary(
      profileId,
      expenses,
      incomes,
      range,
    );
    final dailyPoints = _buildDailyExpenses(expenses, range);
    final weeklyPoints = _buildWeeklyExpenses(expenses, range);
    final monthlyPoints = await _buildMonthlyExpenses(profileId, months: months, now: now);
    final incomeVsExpense = _buildIncomeVsExpense(expenses, incomes);
    final categories = await _buildCategoryBreakdown(profileId, expenses);

    return StatisticsBundle(
      summary: summary,
      dailyPoints: dailyPoints,
      weeklyPoints: weeklyPoints,
      monthlyPoints: monthlyPoints,
      incomeVsExpense: incomeVsExpense,
      trendPoints: dailyPoints,
      categories: categories,
    );
  }

  Future<StatisticsSummary> getSummary(
    int profileId,
    StatisticsPeriod period, {
    DateTime? now,
  }) async {
    final range = period.toDateRange(now: now);
    final expenses = await _expenses.findActiveInRange(
      profileId,
      range.start,
      range.end,
    );
    final incomes = await _incomes.findActiveInRange(
      profileId,
      range.start,
      range.end,
    );
    return _buildSummary(profileId, expenses, incomes, range);
  }

  Future<List<StatisticsChartPoint>> getDailyExpenses(
    int profileId,
    StatisticsPeriod period, {
    DateTime? now,
  }) async {
    final range = period.toDateRange(now: now);
    final expenses = await _expenses.findActiveInRange(
      profileId,
      range.start,
      range.end,
    );
    return _buildDailyExpenses(expenses, range);
  }

  Future<List<StatisticsChartPoint>> getWeeklyExpenses(
    int profileId,
    StatisticsPeriod period, {
    DateTime? now,
  }) async {
    final range = period.toDateRange(now: now);
    final expenses = await _expenses.findActiveInRange(
      profileId,
      range.start,
      range.end,
    );
    return _buildWeeklyExpenses(expenses, range);
  }

  Future<List<StatisticsChartPoint>> getMonthlyExpenses(
    int profileId, {
    int months = 6,
    DateTime? now,
  }) => _buildMonthlyExpenses(profileId, months: months, now: now);

  Future<List<StatisticsChartPoint>> getIncomeVsExpense(
    int profileId,
    StatisticsPeriod period, {
    DateTime? now,
  }) async {
    final range = period.toDateRange(now: now);
    final expenses = await _expenses.findActiveInRange(
      profileId,
      range.start,
      range.end,
    );
    final incomes = await _incomes.findActiveInRange(
      profileId,
      range.start,
      range.end,
    );
    return _buildIncomeVsExpense(expenses, incomes);
  }

  Future<List<StatisticsChartPoint>> getSpendingTrend(
    int profileId,
    StatisticsPeriod period, {
    DateTime? now,
  }) =>
      getDailyExpenses(profileId, period, now: now);

  Future<List<CategoryStatistic>> getCategoryBreakdown(
    int profileId,
    StatisticsPeriod period, {
    DateTime? now,
    int limit = 8,
  }) async {
    final range = period.toDateRange(now: now);
    final expenses = await _expenses.findActiveInRange(
      profileId,
      range.start,
      range.end,
    );
    return _buildCategoryBreakdown(profileId, expenses, limit: limit);
  }

  Future<StatisticsSummary> _buildSummary(
    int profileId,
    List<Expense> expenses,
    List<Income> incomes,
    DateRange range,
  ) async {
    final totalExpense =
        expenses.fold<double>(0, (sum, e) => sum + e.amount);
    final totalIncome = incomes.fold<double>(0, (sum, i) => sum + i.amount);

    final dayCount = range.end.difference(range.start).inDays + 1;
    final avgDaily = dayCount > 0 ? totalExpense / dayCount : 0.0;

    Expense? largest;
    for (final expense in expenses) {
      if (largest == null || expense.amount > largest.amount) {
        largest = expense;
      }
    }

    String? largestLabel;
    if (largest != null) {
      final categories = await _categories.findByProfile(profileId);
      final categoryMap = {for (final c in categories) c.id: c};
      largestLabel = largest.notes?.isNotEmpty == true
          ? largest.notes!
          : (categoryMap[largest.categoryId]?.name ?? 'Expense');
    }

    return StatisticsSummary(
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      savings: totalIncome - totalExpense,
      averageDailySpending: avgDaily,
      largestExpenseAmount: largest?.amount,
      largestExpenseLabel: largestLabel,
    );
  }

  List<StatisticsChartPoint> _buildDailyExpenses(
    List<Expense> expenses,
    DateRange range,
  ) {
    final points = <StatisticsChartPoint>[];
    var cursor = range.start.startOfDay;
    final end = range.end.startOfDay;
    while (!cursor.isAfter(end)) {
      final dayEnd = cursor.endOfDay;
      final total = expenses
          .where((e) => e.date.isBetween(cursor, dayEnd))
          .fold<double>(0, (sum, e) => sum + e.amount);
      points.add(
        StatisticsChartPoint(
          label: DateFormat('d').format(cursor),
          amount: total,
          date: cursor,
        ),
      );
      cursor = cursor.add(const Duration(days: 1));
    }
    return points;
  }

  List<StatisticsChartPoint> _buildWeeklyExpenses(
    List<Expense> expenses,
    DateRange range,
  ) {
    final points = <StatisticsChartPoint>[];
    var weekStart = range.start.startOfWeek;
    var weekIndex = 1;
    while (!weekStart.isAfter(range.end)) {
      final weekEnd = weekStart.add(const Duration(days: 6)).endOfDay;
      final effectiveEnd = weekEnd.isBefore(range.end) ? weekEnd : range.end;
      final total = expenses
          .where((e) => e.date.isBetween(weekStart, effectiveEnd))
          .fold<double>(0, (sum, e) => sum + e.amount);
      points.add(
        StatisticsChartPoint(
          label: 'W$weekIndex',
          amount: total,
          date: weekStart,
        ),
      );
      weekStart = weekStart.add(const Duration(days: 7));
      weekIndex++;
    }
    return points;
  }

  Future<List<StatisticsChartPoint>> _buildMonthlyExpenses(
    int profileId, {
    int months = 6,
    DateTime? now,
  }) async {
    final reference = now ?? DateTime.now();
    final formatter = DateFormat('MMM');
    final start = DateTime(reference.year, reference.month - (months - 1), 1);
    final end = DateTime(reference.year, reference.month + 1, 0, 23, 59, 59);
    final expenses = await _expenses.findActiveInRange(profileId, start, end);
    final points = <StatisticsChartPoint>[];

    for (var i = months - 1; i >= 0; i--) {
      final monthDate = DateTime(reference.year, reference.month - i, 1);
      final monthStart = monthDate.startOfMonth;
      final monthEnd = monthDate.endOfMonth;
      final total = expenses
          .where((e) => e.date.isBetween(monthStart, monthEnd))
          .fold<double>(0, (sum, e) => sum + e.amount);
      points.add(
        StatisticsChartPoint(
          label: formatter.format(monthStart),
          amount: total,
          date: monthStart,
        ),
      );
    }
    return points;
  }

  List<StatisticsChartPoint> _buildIncomeVsExpense(
    List<Expense> expenses,
    List<Income> incomes,
  ) {
    final expenseTotal =
        expenses.fold<double>(0, (sum, e) => sum + e.amount);
    final incomeTotal = incomes.fold<double>(0, (sum, i) => sum + i.amount);
    return [
      StatisticsChartPoint(label: 'income', amount: incomeTotal),
      StatisticsChartPoint(label: 'expense', amount: expenseTotal),
    ];
  }

  Future<List<CategoryStatistic>> _buildCategoryBreakdown(
    int profileId,
    List<Expense> expenses, {
    int limit = 8,
  }) async {
    final categories = await _categories.findByProfile(profileId);
    final categoryMap = {for (final c in categories) c.id: c};

    final totals = <int, double>{};
    for (final expense in expenses) {
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
    return stats.take(limit).toList();
  }
}
