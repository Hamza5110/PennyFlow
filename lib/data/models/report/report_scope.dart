import 'package:equatable/equatable.dart';

import '../../../core/extensions/date_extensions.dart';
import '../../../core/utils/app_date_utils.dart';

enum ReportType { monthly, yearly, custom }

enum ReportFormat { pdf, excel, csv }

/// User-selected report configuration (FR-111–FR-113).
class ReportScope extends Equatable {
  const ReportScope({
    required this.type,
    required this.from,
    required this.to,
    this.includeIncome = true,
    this.includeExpenses = true,
    this.includeFriends = true,
    this.includeCategorySummary = true,
    this.includeMonthlySummary = false,
  });

  final ReportType type;
  final DateTime from;
  final DateTime to;
  final bool includeIncome;
  final bool includeExpenses;
  final bool includeFriends;
  final bool includeCategorySummary;
  final bool includeMonthlySummary;

  factory ReportScope.monthly({
    required int year,
    required int month,
    bool includeIncome = true,
    bool includeExpenses = true,
    bool includeFriends = true,
    bool includeCategorySummary = true,
  }) {
    final start = DateTime(year, month).startOfMonth;
    final end = start.endOfMonth;
    return ReportScope(
      type: ReportType.monthly,
      from: start,
      to: end,
      includeIncome: includeIncome,
      includeExpenses: includeExpenses,
      includeFriends: includeFriends,
      includeCategorySummary: includeCategorySummary,
    );
  }

  factory ReportScope.yearly({
    required int year,
    bool includeIncome = true,
    bool includeExpenses = true,
    bool includeFriends = true,
    bool includeCategorySummary = true,
  }) {
    final start = DateTime(year).startOfMonth;
    final end = DateTime(year, 12, 31).endOfDay;
    return ReportScope(
      type: ReportType.yearly,
      from: start,
      to: end,
      includeIncome: includeIncome,
      includeExpenses: includeExpenses,
      includeFriends: includeFriends,
      includeCategorySummary: includeCategorySummary,
      includeMonthlySummary: true,
    );
  }

  factory ReportScope.custom({
    required DateTime from,
    required DateTime to,
    bool includeIncome = true,
    bool includeExpenses = true,
    bool includeFriends = true,
    bool includeCategorySummary = true,
    bool includeMonthlySummary = false,
  }) {
    return ReportScope(
      type: ReportType.custom,
      from: from.startOfDay,
      to: to.endOfDay,
      includeIncome: includeIncome,
      includeExpenses: includeExpenses,
      includeFriends: includeFriends,
      includeCategorySummary: includeCategorySummary,
      includeMonthlySummary: includeMonthlySummary,
    );
  }

  DateRange get dateRange => DateRange(start: from, end: to);

  String get typeLabelKey {
    switch (type) {
      case ReportType.monthly:
        return 'reports_type_monthly';
      case ReportType.yearly:
        return 'reports_type_yearly';
      case ReportType.custom:
        return 'reports_type_custom';
    }
  }

  static String extensionFor(ReportFormat format) {
    switch (format) {
      case ReportFormat.pdf:
        return 'pdf';
      case ReportFormat.excel:
        return 'xlsx';
      case ReportFormat.csv:
        return 'csv';
    }
  }

  @override
  List<Object?> get props => [
        type,
        from,
        to,
        includeIncome,
        includeExpenses,
        includeFriends,
        includeCategorySummary,
        includeMonthlySummary,
      ];
}
