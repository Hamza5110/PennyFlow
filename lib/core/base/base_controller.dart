import 'package:get/get.dart';

import '../errors/error_handler.dart';
import '../errors/service_result.dart';
import '../logging/app_logger.dart';

/// Lightweight GetX controller base.
///
/// Controllers must:
/// - Hold UI-facing reactive state only
/// - Delegate business logic to services
/// - Never touch Isar / repositories directly
///
/// Controllers must not:
/// - Contain domain rules or persistence logic
/// - Perform long-running work without updating [isLoading]
abstract class BaseController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();

  AppLogger get log => AppLogger.instance;

  /// Runs an async action with loading + standardized error handling.
  Future<T?> runGuarded<T>(
    Future<T> Function() action, {
    bool showErrorSnackbar = true,
    bool trackLoading = true,
  }) async {
    try {
      if (trackLoading) isLoading.value = true;
      errorMessage.value = null;
      return await action();
    } catch (error, stackTrace) {
      final failure = ErrorHandler.handle(
        error,
        stackTrace: stackTrace,
        showSnackbar: showErrorSnackbar,
      );
      errorMessage.value = failure.message;
      return null;
    } finally {
      if (trackLoading) isLoading.value = false;
    }
  }

  /// Unwraps a [ServiceResult], showing errors when unsuccessful.
  T? unwrapResult<T>(
    ServiceResult<T> result, {
    bool showErrorSnackbar = true,
  }) {
    if (result.success) return result.data;
    errorMessage.value = result.userMessage;
    if (showErrorSnackbar && result.userMessage != null) {
      ErrorHandler.showError(result.userMessage!);
    }
    return null;
  }

  void clearError() => errorMessage.value = null;
}
