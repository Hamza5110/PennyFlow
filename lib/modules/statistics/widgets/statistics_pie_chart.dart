import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/formatters.dart';
import '../../../data/models/statistics/category_statistic.dart';

class StatisticsPieChart extends StatelessWidget {
  const StatisticsPieChart({
    super.key,
    required this.categories,
    required this.currencyCode,
    this.height = 220,
  });

  final List<CategoryStatistic> categories;
  final String currencyCode;
  final double height;

  Color _parseColor(String hex) {
    final cleaned = hex.replaceFirst('#', '');
    return Color(int.parse('FF$cleaned', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (categories.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(child: Text('statistics_no_data'.tr)),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: height,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 48,
              sections: [
                for (final item in categories)
                  PieChartSectionData(
                    value: item.amount,
                    title: '${(item.percentage * 100).toStringAsFixed(0)}%',
                    color: _parseColor(item.colorHex),
                    radius: 56,
                    titleStyle: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            for (final item in categories)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: _parseColor(item.colorHex),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${item.name} · ${AppFormatters.currency(item.amount, currencyCode: currencyCode)}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }
}
