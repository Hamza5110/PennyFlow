import 'package:intl/intl.dart';

import '../../core/base/base_repository.dart';
import '../../core/extensions/date_extensions.dart';
import '../../core/utils/app_date_utils.dart';
import '../models/expense.dart';
import '../models/income.dart';
import '../models/statistics/category_statistic.dart';
import '../models/statistics/statistics_chart_point.dart';
import '../models/statistics/statistics_period.dart';
import '../models/statistics/statistics_summary.dart';
import 'category_repository.dart';
import 'expense_repository.dart';
import 'income_repository.dart';

/// Aggregates expense/income data for statistics charts (Phase 11).
class StatisticsRepository extends BaseRepository {
  StatisticsRepository(
    this._expenses,
    this._incomes,
    this._categories,
  );

  final ExpenseRepository _expenses;
  final IncomeRepository _incomes;
  final CategoryRepository _categories;

  Future<StatisticsSummary> getSummary(
    int profileId,
    StatisticsPeriod period, {
    DateTime? now,
  }) async {
    final range = period.toDateRange(now: now);
    final expenses = await _filterExpenses(profileId, range);
    final incomes = await _filterIncomes(profileId, range);

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

  Future<List<StatisticsChartPoint>> getDailyExpenses(
    int profileId,
    StatisticsPeriod period, {
    DateTime? now,
  }) async {
    final range = period.toDateRange(now: now);
    final expenses = await _filterExpenses(profileId, range);
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

  Future<List<StatisticsChartPoint>> getWeeklyExpenses(
    int profileId,
    StatisticsPeriod period, {
    DateTime? now,
  }) async {
    final range = period.toDateRange(now: now);
    final expenses = await _filterExpenses(profileId, range);
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

  Future<List<StatisticsChartPoint>> getMonthlyExpenses(
    int profileId, {
    int months = 6,
    DateTime? now,
  }) async {
    final reference = now ?? DateTime.now();
    final formatter = DateFormat('MMM');
    final expenses = await _expenses.findActiveByProfile(profileId);
    final points = <StatisticsChartPoint>[];

    for (var i = months - 1; i >= 0; i--) {
      final monthDate = DateTime(reference.year, reference.month - i, 1);
      final start = monthDate.startOfMonth;
      final end = monthDate.endOfMonth;
      final total = expenses
          .where((e) => e.date.isBetween(start, end))
          .fold<double>(0, (sum, e) => sum + e.amount);
      points.add(
        StatisticsChartPoint(
          label: formatter.format(start),
          amount: total,
          date: start,
        ),
      );
    }
    return points;
  }

  Future<List<StatisticsChartPoint>> getIncomeVsExpense(
    int profileId,
    StatisticsPeriod period, {
    DateTime? now,
  }) async {
    final range = period.toDateRange(now: now);
    final expenses = await _filterExpenses(profileId, range);
    final incomes = await _filterIncomes(profileId, range);

    final expenseTotal =
        expenses.fold<double>(0, (sum, e) => sum + e.amount);
    final incomeTotal = incomes.fold<double>(0, (sum, i) => sum + i.amount);

    return [
      StatisticsChartPoint(label: 'income', amount: incomeTotal),
      StatisticsChartPoint(label: 'expense', amount: expenseTotal),
    ];
  }

  Future<List<StatisticsChartPoint>> getSpendingTrend(
    int profileId,
    StatisticsPeriod period, {
    DateTime? now,
  }) async => getDailyExpenses(profileId, period, now: now);

  Future<List<CategoryStatistic>> getCategoryBreakdown(
    int profileId,
    StatisticsPeriod period, {
    DateTime? now,
    int limit = 8,
  }) async {
    final range = period.toDateRange(now: now);
    final expenses = await _filterExpenses(profileId, range);
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

  Future<List<Expense>> _filterExpenses(int profileId, DateRange range) async {
    final expenses = await _expenses.findActiveByProfile(profileId);
    return expenses.where((e) => range.contains(e.date)).toList();
  }

  Future<List<Income>> _filterIncomes(int profileId, DateRange range) async {
    final incomes = await _incomes.findActiveByProfile(profileId);
    return incomes.where((i) => range.contains(i.date)).toList();
  }
}
