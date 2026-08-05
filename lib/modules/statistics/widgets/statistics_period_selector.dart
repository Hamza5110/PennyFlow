import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/statistics/statistics_period.dart';

class StatisticsPeriodSelector extends StatelessWidget {
  const StatisticsPeriodSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final StatisticsPeriod selected;
  final ValueChanged<StatisticsPeriod> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: StatisticsPeriod.values.map((period) {
          final isSelected = period == selected;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(period.labelKey.tr),
              selected: isSelected,
              onSelected: (_) => onChanged(period),
              showCheckmark: false,
            ),
          );
        }).toList(),
      ),
    );
  }
}
