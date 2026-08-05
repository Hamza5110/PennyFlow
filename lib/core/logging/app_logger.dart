import 'package:logger/logger.dart';

/// Application-wide logger wrapper.
///
/// Use [AppLogger.instance] everywhere instead of `print` / raw [Logger].
/// Controllers and services should log at appropriate levels; never log PINs,
/// tokens, or full backup payloads.
class AppLogger {
  AppLogger._()
      : _logger = Logger(
          printer: PrettyPrinter(
            methodCount: 2,
            errorMethodCount: 8,
            lineLength: 100,
            colors: true,
            printEmojis: false,
            dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
          ),
          level: Level.debug,
        );

  static final AppLogger instance = AppLogger._();

  final Logger _logger;

  void d(dynamic message, {Object? error, StackTrace? stackTrace}) =>
      _logger.d(message, error: error, stackTrace: stackTrace);

  void i(dynamic message, {Object? error, StackTrace? stackTrace}) =>
      _logger.i(message, error: error, stackTrace: stackTrace);

  void w(dynamic message, {Object? error, StackTrace? stackTrace}) =>
      _logger.w(message, error: error, stackTrace: stackTrace);

  void e(dynamic message, {Object? error, StackTrace? stackTrace}) =>
      _logger.e(message, error: error, stackTrace: stackTrace);

  void f(dynamic message, {Object? error, StackTrace? stackTrace}) =>
      _logger.f(message, error: error, stackTrace: stackTrace);

  void log(
    Level level,
    dynamic message, {
    Object? error,
    StackTrace? stackTrace,
  }) =>
      _logger.log(level, message, error: error, stackTrace: stackTrace);

  /// Call early in bootstrap to silence verbose logs in release builds.
  void configure({required bool isDebug}) {
    Logger.level = isDebug ? Level.debug : Level.warning;
  }
}
