import 'package:flutter/foundation.dart';

/// Compile-time / runtime environment configuration.
///
/// Pass `--dart-define=ENV=staging` (or production/dev) at build time.
enum AppEnvironment { development, staging, production }

class EnvConfig {
  const EnvConfig._({
    required this.environment,
    required this.appDisplayName,
    required this.enableLogging,
    required this.enableCrashReporting,
    required this.updateCheckUrl,
    required this.githubOwner,
    required this.githubRepo,
    required this.googleServerClientId,
  });

  final AppEnvironment environment;
  final String appDisplayName;
  final bool enableLogging;
  final bool enableCrashReporting;

  /// GitHub Releases API endpoint for in-app updates (FR-167+).
  final String updateCheckUrl;
  final String githubOwner;
  final String githubRepo;

  /// OAuth 2.0 Web client ID for Google Sign-In (dart-define).
  final String googleServerClientId;

  bool get isDevelopment => environment == AppEnvironment.development;
  bool get isProduction => environment == AppEnvironment.production;

  static late EnvConfig current;

  static void init() {
    const envName = String.fromEnvironment('ENV', defaultValue: 'development');
    const githubOwner = String.fromEnvironment(
      'GITHUB_OWNER',
      defaultValue: 'Hamza5110',
    );
    const githubRepo = String.fromEnvironment(
      'GITHUB_REPO',
      defaultValue: 'PennyFlow',
    );
    const googleServerClientId = String.fromEnvironment(
      'GOOGLE_SERVER_CLIENT_ID',
      defaultValue: '',
    );

    final environment = switch (envName.toLowerCase()) {
      'staging' => AppEnvironment.staging,
      'production' || 'prod' => AppEnvironment.production,
      _ => AppEnvironment.development,
    };

    current = EnvConfig._(
      environment: environment,
      appDisplayName: switch (environment) {
        AppEnvironment.development => 'SpendVault Dev',
        AppEnvironment.staging => 'SpendVault Staging',
        AppEnvironment.production => 'SpendVault',
      },
      enableLogging: environment != AppEnvironment.production || kDebugMode,
      enableCrashReporting: environment == AppEnvironment.production,
      githubOwner: githubOwner,
      githubRepo: githubRepo,
      googleServerClientId: googleServerClientId,
      updateCheckUrl:
          'https://api.github.com/repos/$githubOwner/$githubRepo/releases/latest',
    );
  }
}
