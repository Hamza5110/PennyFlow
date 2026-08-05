import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../data/models/statistics/statistics_chart_point.dart';

class StatisticsIncomeExpenseChart extends StatelessWidget {
  const StatisticsIncomeExpenseChart({
    super.key,
    required this.points,
    this.height = 220,
  });

  final List<StatisticsChartPoint> points;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (points.length < 2) {
      return SizedBox(
        height: height,
        child: Center(child: Text('statistics_no_data'.tr)),
      );
    }

    final income = points.firstWhere(
      (p) => p.label == 'income',
      orElse: () => const StatisticsChartPoint(label: 'income', amount: 0),
    );
    final expense = points.firstWhere(
      (p) => p.label == 'expense',
      orElse: () => const StatisticsChartPoint(label: 'expense', amount: 0),
    );

    final maxY = [income.amount, expense.amount]
        .fold<double>(0, (a, b) => a > b ? a : b)
        .clamp(1, double.infinity);

    return SizedBox(
      height: height,
      child: BarChart(
        BarChartData(
          maxY: maxY * 1.2,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
            leftTitles: const AxisTitles(),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text('statistics_income'.tr),
                    );
                  }
                  if (index == 1) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text('statistics_expense'.tr),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
          barGroups: [
            BarChartGroupData(
              x: 0,
              barRods: [
                BarChartRodData(
                  toY: income.amount,
                  width: 36,
                  color: AppColors.income,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6),
                  ),
                ),
              ],
            ),
            BarChartGroupData(
              x: 1,
              barRods: [
                BarChartRodData(
                  toY: expense.amount,
                  width: 36,
                  color: AppColors.expense,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
