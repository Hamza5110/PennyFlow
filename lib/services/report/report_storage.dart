import 'dart:io';

import 'package:flutter/services.dart';

import '../../data/models/report/report_scope.dart';

/// Saves generated reports to the public Downloads folder on Android.
class ReportStorage {
  ReportStorage._();

  static const MethodChannel _channel =
      MethodChannel('com.pennyflow.app/report_storage');

  static Future<String> saveToDownloads({
    required String sourcePath,
    required String displayName,
    required ReportFormat format,
  }) async {
    if (!Platform.isAndroid) {
      return sourcePath;
    }

    final mimeType = _mimeTypeFor(format);
    final path = await _channel.invokeMethod<String>(
      'saveToDownloads',
      {
        'sourcePath': sourcePath,
        'displayName': displayName,
        'mimeType': mimeType,
      },
    );
    return path ?? sourcePath;
  }

  static String _mimeTypeFor(ReportFormat format) {
    switch (format) {
      case ReportFormat.pdf:
        return 'application/pdf';
      case ReportFormat.excel:
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case ReportFormat.csv:
        return 'text/csv';
    }
  }
}
