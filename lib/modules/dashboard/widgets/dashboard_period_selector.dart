import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/dashboard/dashboard_period.dart';

class DashboardPeriodSelector extends StatelessWidget {
  const DashboardPeriodSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final DashboardPeriod selected;
  final ValueChanged<DashboardPeriod> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: DashboardPeriod.values.map((period) {
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
