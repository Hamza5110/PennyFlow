import 'package:flutter/material.dart';

import 'app/app_initializer.dart';
import 'app/penny_flow_app.dart';
import 'core/errors/error_handler.dart';
import 'core/logging/app_logger.dart';

Future<void> main() async {
  try {
    await AppInitializer.init();
    runApp(const PennyFlowApp());
  } catch (error, stackTrace) {
    AppLogger.instance.f(
      'Fatal bootstrap error',
      error: error,
      stackTrace: stackTrace,
    );
    ErrorHandler.installGlobalHandlers();
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'PennyFlow failed to start.\n${ErrorHandler.userMessage(error)}',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
