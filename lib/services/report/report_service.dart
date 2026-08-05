import 'dart:io';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/base/base_service.dart';
import '../../core/errors/app_exception.dart';
import '../../core/errors/service_result.dart';
import '../../data/models/report/report_data.dart';
import '../../data/models/report/report_scope.dart';
import '../../data/repositories/report_repository.dart';
import '../settings/settings_service.dart';
import 'report_csv_generator.dart';
import 'report_excel_generator.dart';
import 'report_pdf_generator.dart';

class ReportService extends GetxService with BaseService {
  ReportService(this._repository, this._settings);

  final ReportRepository _repository;
  final SettingsService _settings;

  Future<ServiceResult<ReportGeneratedFile>> generatePdf(
    ReportScope scope,
  ) =>
      _generate(scope, ReportFormat.pdf);

  Future<ServiceResult<ReportGeneratedFile>> generateExcel(
    ReportScope scope,
  ) =>
      _generate(scope, ReportFormat.excel);

  Future<ServiceResult<ReportGeneratedFile>> generateCsv(
    ReportScope scope,
  ) =>
      _generate(scope, ReportFormat.csv);

  Future<ServiceResult<void>> shareReport(ReportGeneratedFile file) async {
    return guardVoid(() async {
      final xFile = XFile(file.path, name: file.fileName);
      await Share.shareXFiles([xFile], text: 'PennyFlow report');
    }, fallbackMessage: 'reports_share_failed'.tr);
  }

  Future<ServiceResult<ReportGeneratedFile>> _generate(
    ReportScope scope,
    ReportFormat format,
  ) async {
    return guard(() async {
      final profileId = _settings.activeProfileId;
      if (profileId == null) {
        throw const ValidationException(message: 'No active profile');
      }

      final data = await _repository.buildReportData(
        profileId: profileId,
        scope: scope,
        currencyCode: _settings.currencyCode.value,
      );

      final fileName = _buildFileName(scope, format);
      final filePath = await _resolveOutputPath(fileName);

      switch (format) {
        case ReportFormat.pdf:
          await ReportPdfGenerator.writeToFile(data: data, path: filePath);
        case ReportFormat.excel:
          await ReportExcelGenerator.writeToFile(data: data, path: filePath);
        case ReportFormat.csv:
          await ReportCsvGenerator.writeToFile(data: data, path: filePath);
      }

      return ReportGeneratedFile(
        path: filePath,
        fileName: fileName,
        format: format,
      );
    }, fallbackMessage: 'reports_generate_failed'.tr);
  }

  String _buildFileName(ReportScope scope, ReportFormat format) {
    final dateFmt = DateFormat('yyyyMMdd');
    final from = dateFmt.format(scope.from);
    final to = dateFmt.format(scope.to);
    final ext = ReportScope.extensionFor(format);
    return 'pennyflow_report_${from}_$to.$ext';
  }

  Future<String> _resolveOutputPath(String fileName) async {
    final dir = await getApplicationDocumentsDirectory();
    final reportsDir = Directory(p.join(dir.path, 'reports'));
    if (!await reportsDir.exists()) {
      await reportsDir.create(recursive: true);
    }
    return p.join(reportsDir.path, fileName);
  }
}
