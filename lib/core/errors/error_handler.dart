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
    _showFeedback(
      title: 'common_error'.tr,
      message: message,
      isError: true,
    );
  }

  static void showSuccess(String message) {
    _showFeedback(
      title: 'common_success'.tr,
      message: message,
      isError: false,
    );
  }

  /// Pops the current route, then shows a success snackbar on the previous screen.
  static void popWithSuccess(String message, {dynamic result = true}) {
    if (Get.key.currentState?.canPop() == true) {
      Get.back(result: result);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showSuccess(message);
    });
  }

  static void _showFeedback({
    required String title,
    required String message,
    required bool isError,
  }) {
    final context = Get.overlayContext ?? Get.context;
    if (context != null) {
      final messenger = ScaffoldMessenger.maybeOf(context);
      if (messenger != null) {
        messenger.clearSnackBars();
        final theme = Theme.of(context);
        final colors = theme.colorScheme;
        final foreground = isError
            ? colors.onErrorContainer
            : colors.onPrimaryContainer;
        messenger.showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: foreground,
                  ),
                ),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(12),
            backgroundColor:
                isError ? colors.errorContainer : colors.primaryContainer,
            duration: Duration(seconds: isError ? 3 : 2),
          ),
        );
        return;
      }
    }

    if (Get.isSnackbarOpen == true) {
      Get.closeCurrentSnackbar();
    }
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
      backgroundColor: isError
          ? Get.theme.colorScheme.errorContainer
          : Get.theme.colorScheme.primaryContainer,
      colorText: isError
          ? Get.theme.colorScheme.onErrorContainer
          : Get.theme.colorScheme.onPrimaryContainer,
      duration: Duration(seconds: isError ? 3 : 2),
    );
  }

  static String userMessage(Object error) {
    if (error is AppException) return error.message;
    return 'Something went wrong. Please try again.';
  }
}
