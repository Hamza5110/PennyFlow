import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../core/base/base_service.dart';
import '../../core/constants/storage_keys.dart';
import '../settings/settings_service.dart';
import '../recurring/recurring_service.dart';
import '../startup/startup_service.dart';
import '../storage/local_storage_service.dart';

/// Observes app foreground/background transitions (Phase 1).
class AppLifecycleService extends GetxService
    with WidgetsBindingObserver, BaseService {
  AppLifecycleService(
    this._settings,
    this._storage,
    this._startup,
    this._recurring,
  );

  final SettingsService _settings;
  final LocalStorageService _storage;
  final StartupService _startup;
  final RecurringService _recurring;

  final Rx<AppLifecycleState> lifecycleState =
      AppLifecycleState.resumed.obs;

  bool _isHandlingResume = false;

  Future<AppLifecycleService> init() async {
    WidgetsBinding.instance.addObserver(this);
    lifecycleState.value = AppLifecycleState.resumed;
    log.i('AppLifecycleService observing');
    return this;
  }

  bool get isInForeground => lifecycleState.value == AppLifecycleState.resumed;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    lifecycleState.value = state;
    log.d('Lifecycle → ${state.name}');

    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _onBackground();
      case AppLifecycleState.resumed:
        unawaited(_onForeground());
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        break;
    }
  }

  void _onBackground() {
    _settings.lockSession();
    unawaited(
      _storage.setString(
        StorageKeys.lastBackgroundAt,
        DateTime.now().toIso8601String(),
      ),
    );
  }

  Future<void> _onForeground() async {
    if (_isHandlingResume) return;
    _isHandlingResume = true;
    try {
      if (_settings.activeProfileId != null) {
        await _recurring.processDueTemplates();
      }

      if (!_settings.isAppLockEnabled) return;

      final shouldLock = _settings.shouldLockAfterBackground();
      if (!shouldLock) return;

      _settings.lockSession();
      final route = await _startup.resolveResumeRoute();
      if (Get.currentRoute != route) {
        await Get.offAllNamed(route);
      }
    } finally {
      _isHandlingResume = false;
    }
  }

  void unlockSession() => _settings.unlockSession();

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }
}
