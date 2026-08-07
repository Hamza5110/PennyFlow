import 'package:get/get.dart';

import '../../../core/base/base_controller.dart';
import '../../../core/errors/error_handler.dart';
import '../../../core/utils/app_date_utils.dart';
import '../../../core/widgets/date_filter_section.dart';
import '../../../data/models/report/report_data.dart';
import '../../../data/models/report/report_scope.dart';
import '../../../services/report/report_service.dart';

class ReportsController extends BaseController {
  ReportsController(this._reports);

  final ReportService _reports;

  final Rx<ReportType> reportType = ReportType.monthly.obs;
  final Rx<ReportFormat> format = ReportFormat.pdf.obs;
  final RxInt selectedMonth = DateTime.now().month.obs;
  final RxInt selectedYear = DateTime.now().year.obs;
  final Rxn<DateRange> customRange = Rxn<DateRange>();

  final RxBool includeIncome = true.obs;
  final RxBool includeExpenses = true.obs;
  final RxBool includeFriends = true.obs;
  final RxBool includeCategorySummary = true.obs;

  final Rxn<ReportGeneratedFile> lastGenerated = Rxn<ReportGeneratedFile>();

  void setReportType(ReportType value) => reportType.value = value;

  void setFormat(ReportFormat value) => format.value = value;

  void setMonth(int value) => selectedMonth.value = value;

  void setYear(int value) => selectedYear.value = value;

  void setCustomRange(DateFilterSelection selection) {
    if (selection.period == DatePeriod.custom && selection.customRange != null) {
      customRange.value = selection.customRange;
    }
  }

  ReportScope buildScope() {
    final includeSections = (
      income: includeIncome.value,
      expenses: includeExpenses.value,
      friends: includeFriends.value,
      categories: includeCategorySummary.value,
    );

    switch (reportType.value) {
      case ReportType.monthly:
        return ReportScope.monthly(
          year: selectedYear.value,
          month: selectedMonth.value,
          includeIncome: includeSections.income,
          includeExpenses: includeSections.expenses,
          includeFriends: includeSections.friends,
          includeCategorySummary: includeSections.categories,
        );
      case ReportType.yearly:
        return ReportScope.yearly(
          year: selectedYear.value,
          includeIncome: includeSections.income,
          includeExpenses: includeSections.expenses,
          includeFriends: includeSections.friends,
          includeCategorySummary: includeSections.categories,
        );
      case ReportType.custom:
        final range = customRange.value;
        if (range == null) {
          throw StateError('Custom range not set');
        }
        return ReportScope.custom(
          from: range.start,
          to: range.end,
          includeIncome: includeSections.income,
          includeExpenses: includeSections.expenses,
          includeFriends: includeSections.friends,
          includeCategorySummary: includeSections.categories,
          includeMonthlySummary:
              range.end.difference(range.start).inDays > 31,
        );
    }
  }

  Future<void> generateReport() async {
    if (reportType.value == ReportType.custom && customRange.value == null) {
      ErrorHandler.showError('reports_custom_range_required'.tr);
      return;
    }

    await runGuarded(() async {
      final scope = buildScope();
      final selectedFormat = format.value;

      final result = switch (selectedFormat) {
        ReportFormat.pdf => await _reports.generatePdf(scope),
        ReportFormat.excel => await _reports.generateExcel(scope),
        ReportFormat.csv => await _reports.generateCsv(scope),
      };

      if (!result.success || result.data == null) {
        ErrorHandler.showError(
          result.userMessage ?? 'reports_generate_failed'.tr,
        );
        return;
      }

      lastGenerated.value = result.data;
      ErrorHandler.showSuccess(
        'reports_generated'.trParams({'file': result.data!.fileName}),
      );
    });
  }

  Future<void> shareLastReport() async {
    final file = lastGenerated.value;
    if (file == null) return;

    final result = await _reports.shareReport(file);
    if (!result.success) {
      ErrorHandler.showError(
        result.userMessage ?? 'reports_share_failed'.tr,
      );
    }
  }
}
