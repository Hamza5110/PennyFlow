import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../utils/app_date_utils.dart';

typedef DateFilterSelection = ({
  DatePeriod? period,
  DateRange? customRange,
});

/// Reusable date filter controls (FR-105).
class DateFilterSection extends StatefulWidget {
  const DateFilterSection({
    super.key,
    required this.initialPeriod,
    required this.initialCustomRange,
    required this.onChanged,
    this.label,
  });

  final DatePeriod? initialPeriod;
  final DateRange? initialCustomRange;
  final ValueChanged<DateFilterSelection> onChanged;
  final String? label;

  @override
  State<DateFilterSection> createState() => _DateFilterSectionState();
}

class _DateFilterSectionState extends State<DateFilterSection> {
  late DatePeriod? _period;
  DateTime? _customStart;
  DateTime? _customEnd;

  @override
  void initState() {
    super.initState();
    _period = widget.initialPeriod;
    _customStart = widget.initialCustomRange?.start;
    _customEnd = widget.initialCustomRange?.end;
  }

  void _emit() {
    final customRange = _period == DatePeriod.custom &&
            _customStart != null &&
            _customEnd != null
        ? DateRange(
            start: _customStart!.copyWith(
              hour: 0,
              minute: 0,
              second: 0,
              millisecond: 0,
            ),
            end: _customEnd!.copyWith(
              hour: 23,
              minute: 59,
              second: 59,
              millisecond: 999,
            ),
          )
        : null;

    widget.onChanged((period: _period, customRange: customRange));
  }

  Future<void> _pickCustomDate({required bool isStart}) async {
    final initial = isStart
        ? (_customStart ?? DateTime.now())
        : (_customEnd ?? _customStart ?? DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _customStart = picked;
      } else {
        _customEnd = picked;
      }
      _period = DatePeriod.custom;
      _emit();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<DatePeriod?>(
          initialValue: _period,
          decoration: InputDecoration(
            labelText: widget.label ?? 'search_date'.tr,
          ),
          items: [
            DropdownMenuItem(value: null, child: Text('search_any_date'.tr)),
            DropdownMenuItem(
              value: DatePeriod.today,
              child: Text('dashboard_period_today'.tr),
            ),
            DropdownMenuItem(
              value: DatePeriod.yesterday,
              child: Text('search_yesterday'.tr),
            ),
            DropdownMenuItem(
              value: DatePeriod.thisWeek,
              child: Text('dashboard_period_week'.tr),
            ),
            DropdownMenuItem(
              value: DatePeriod.thisMonth,
              child: Text('dashboard_period_month'.tr),
            ),
            DropdownMenuItem(
              value: DatePeriod.lastMonth,
              child: Text('search_last_month'.tr),
            ),
            DropdownMenuItem(
              value: DatePeriod.custom,
              child: Text('search_custom_range'.tr),
            ),
          ],
          onChanged: (value) {
            setState(() {
              _period = value;
              if (value != DatePeriod.custom) {
                _customStart = null;
                _customEnd = null;
              }
              _emit();
            });
          },
        ),
        if (_period == DatePeriod.custom) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _pickCustomDate(isStart: true),
                  child: Text(
                    _customStart == null
                        ? 'search_start_date'.tr
                        : '${_customStart!.day}/${_customStart!.month}/${_customStart!.year}',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _pickCustomDate(isStart: false),
                  child: Text(
                    _customEnd == null
                        ? 'search_end_date'.tr
                        : '${_customEnd!.day}/${_customEnd!.month}/${_customEnd!.year}',
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
