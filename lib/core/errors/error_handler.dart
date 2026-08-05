import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../logging/app_logger.dart';
import 'app_exception.dart';

/// Centralized error handling for UI and bootstrap layers.
///
/// Controllers should call [handle] / [showError] rather than showing snackbars
/// ad hoc. Global Flutter / platform errors are wired in [AppInitializer].
abstract final class ErrorHandler {
  static void installGlobalHandlers() {
    FlutterError.onError = (details) {
      AppLogger.instance.e(
        'FlutterError',
        error: details.exception,
        stackTrace: details.stack,
      );
      FlutterError.presentError(details);
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      AppLogger.instance.e(
        'PlatformDispatcher error',
        error: error,
        stackTrace: stack,
      );
      return true;
    };
  }

  /// Logs and optionally surfaces a user-facing message.
  static Failure handle(
    Object error, {
    StackTrace? stackTrace,
    bool showSnackbar = false,
  }) {
    final failure = Failure.fromException(error, stackTrace);
    AppLogger.instance.log(
      failure.logLevel,
      failure.message,
      error: error,
      stackTrace: stackTrace,
    );
    if (showSnackbar) {
      showError(failure.message);
    }
    return failure;
  }

  static void showError(String message) {
    if (Get.isSnackbarOpen == true) {
      Get.closeCurrentSnackbar();
    }
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
      backgroundColor: Get.theme.colorScheme.errorContainer,
      colorText: Get.theme.colorScheme.onErrorContainer,
      duration: const Duration(seconds: 3),
    );
  }

  static void showSuccess(String message) {
    if (Get.isSnackbarOpen == true) {
      Get.closeCurrentSnackbar();
    }
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
      backgroundColor: Get.theme.colorScheme.primaryContainer,
      colorText: Get.theme.colorScheme.onPrimaryContainer,
      duration: const Duration(seconds: 2),
    );
  }

  static String userMessage(Object error) {
    if (error is AppException) return error.message;
    return 'Something went wrong. Please try again.';
  }
}
