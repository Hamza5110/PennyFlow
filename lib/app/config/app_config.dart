import '../../core/constants/app_constants.dart';
import 'env_config.dart';

/// Mutable/app-session configuration derived from [EnvConfig] + defaults.
///
/// Feature modules should read from here (or SettingsService) rather than
/// hard-coding URLs, timeouts, or feature flags.
class AppConfig {
  AppConfig._();

  static final AppConfig instance = AppConfig._();

  String get appName => AppConstants.appName;

  String get displayName => EnvConfig.current.appDisplayName;

  Duration get networkTimeout => AppConstants.networkTimeout;

  int get maxNetworkRetries => AppConstants.maxNetworkRetries;

  String get updateCheckUrl => EnvConfig.current.updateCheckUrl;

  /// Google Drive AppData OAuth scope (SRS §25.2).
  static const String driveAppDataScope =
      'https://www.googleapis.com/auth/drive.appdata';

  /// Google Sign-In scopes for backup ownership only.
  static const List<String> googleSignInScopes = [
    driveAppDataScope,
  ];
}
