import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:get/get.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../core/base/base_service.dart';
import '../../core/logging/app_logger.dart';

/// Local notifications for budgets, recurring, and reminders (FR-134).
class NotificationService extends GetxService with BaseService {
  NotificationService();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String _budgetChannelId = 'spend_vault_budget_alerts_v2';
  static const String _budgetChannelName = 'Budget Alerts';
  static const String _recurringChannelId = 'spend_vault_recurring_v2';
  static const String _recurringChannelName = 'Recurring Transactions';
  static const String _reminderChannelId = 'spend_vault_reminders_v3';
  static const String _reminderChannelName = 'Reminders';
  static const String _updateProgressChannelId = 'spend_vault_updates_progress';
  static const String _updateProgressChannelName = 'App updates';
  static const String _updateCompleteChannelId = 'spend_vault_updates_ready';
  static const String _updateCompleteChannelName = 'Update ready';

  static const int updateNotificationId = 9101;
  static const String updateInstallPayload = 'update_install';
  static const String updateOpenPayload = 'update_open';

  /// delay, vibrate, pause, vibrate (ms) — noticeable even in silent/vibrate mode.
  static final Int64List _vibrationPattern =
      Int64List.fromList(<int>[0, 500, 200, 500]);

  static int _reminderNotificationId(int reminderId) => 10000 + reminderId;

  /// Invoked when the user taps a notification (install / open update).
  void Function(String? payload)? onNotificationTapped;

  String? _pendingLaunchPayload;

  Future<NotificationService> init() async {
    await _configureLocalTimeZone();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initSettings = InitializationSettings(
      android: android,
      iOS: darwin,
      macOS: darwin,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    final launch = await _plugin.getNotificationAppLaunchDetails();
    if (launch?.didNotificationLaunchApp == true) {
      _pendingLaunchPayload = launch?.notificationResponse?.payload;
    }

    await _createChannel(
      _budgetChannelId,
      _budgetChannelName,
      'Budget warning and exceeded alerts',
      Importance.high,
    );
    await _createChannel(
      _recurringChannelId,
      _recurringChannelName,
      'Recurring transaction auto-generation alerts',
      Importance.defaultImportance,
    );
    await _createChannel(
      _reminderChannelId,
      _reminderChannelName,
      'Bill, subscription, and payment reminders',
      Importance.max,
    );
    await _createChannel(
      _updateProgressChannelId,
      _updateProgressChannelName,
      'APK download progress',
      Importance.low,
      playSound: false,
      enableVibration: false,
    );
    await _createChannel(
      _updateCompleteChannelId,
      _updateCompleteChannelName,
      'Update downloaded and ready to install',
      Importance.high,
    );

    // Do not request notification/alarm permissions here — ask only when the
    // user opts into reminders (create/enable) or starts an update download.
    return this;
  }

  void _onNotificationResponse(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) return;
    onNotificationTapped?.call(payload);
  }

  /// Delivers a tap that launched the process, once a handler is registered.
  String? takePendingLaunchPayload() {
    final payload = _pendingLaunchPayload;
    _pendingLaunchPayload = null;
    return payload;
  }

  Future<void> _configureLocalTimeZone() async {
    tz_data.initializeTimeZones();
    if (kIsWeb) return;

    try {
      final timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
      AppLogger.instance.i('Notification timezone set to $timeZoneName');
    } catch (error, stackTrace) {
      AppLogger.instance.w(
        'Failed to resolve device timezone; using absolute DateTime instants',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Requests OS notification permission (Android 13+ / iOS). Safe to call repeatedly.
  Future<bool> requestPermissions() async {
    try {
      if (!kIsWeb && Platform.isAndroid) {
        final android = _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
        final granted = await android?.requestNotificationsPermission();
        AppLogger.instance.i('Notification permission granted=$granted');
        return granted ?? false;
      }

      if (!kIsWeb && Platform.isIOS) {
        final granted = await _plugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(alert: true, badge: true, sound: true);
        return granted ?? false;
      }

      if (!kIsWeb && Platform.isMacOS) {
        final granted = await _plugin
            .resolvePlatformSpecificImplementation<
                MacOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(alert: true, badge: true, sound: true);
        return granted ?? false;
      }
    } catch (error, stackTrace) {
      AppLogger.instance.w(
        'Notification permission request failed',
        error: error,
        stackTrace: stackTrace,
      );
    }
    return false;
  }

  /// Opens system exact-alarm settings when Android blocks precise scheduling.
  ///
  /// When [prompt] is false, only checks current status (used on silent
  /// reschedule at app start so we never interrupt the user).
  Future<bool> ensureExactAlarmPermission({bool prompt = true}) async {
    if (kIsWeb || !Platform.isAndroid) return true;

    try {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (android == null) return false;

      final canSchedule =
          await android.canScheduleExactNotifications() ?? false;
      if (canSchedule) return true;
      if (!prompt) return false;

      AppLogger.instance.i('Requesting exact alarm permission');
      await android.requestExactAlarmsPermission();
      final granted = await android.canScheduleExactNotifications() ?? false;
      AppLogger.instance.i('Exact alarm permission granted=$granted');
      return granted;
    } catch (error, stackTrace) {
      AppLogger.instance.w(
        'Exact alarm permission request failed',
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Requests notification + exact-alarm access when the user is actively
  /// enabling or creating reminders.
  Future<void> ensureReminderPermissions({bool prompt = true}) async {
    if (!prompt) return;
    await requestPermissions();
    await ensureExactAlarmPermission(prompt: true);
  }

  Future<AndroidScheduleMode> _androidScheduleMode({
    bool promptForExact = false,
  }) async {
    if (kIsWeb || !Platform.isAndroid) {
      return AndroidScheduleMode.exactAllowWhileIdle;
    }

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final canExact = await android?.canScheduleExactNotifications() ?? false;
    if (canExact) return AndroidScheduleMode.exactAllowWhileIdle;

    if (promptForExact) {
      await ensureExactAlarmPermission(prompt: true);
      final canExactAfterRequest =
          await android?.canScheduleExactNotifications() ?? false;
      if (canExactAfterRequest) {
        return AndroidScheduleMode.exactAllowWhileIdle;
      }
    }

    return AndroidScheduleMode.inexactAllowWhileIdle;
  }

  Future<void> _createChannel(
    String id,
    String name,
    String description,
    Importance importance, {
    bool playSound = true,
    bool enableVibration = true,
  }) async {
    final channel = AndroidNotificationChannel(
      id,
      name,
      description: description,
      importance: importance,
      playSound: playSound,
      enableVibration: enableVibration,
      vibrationPattern: enableVibration ? _vibrationPattern : null,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  AndroidNotificationDetails _androidDetails({
    required String channelId,
    required String channelName,
    String? channelDescription,
    String? ticker,
  }) {
    return AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.max,
      priority: Priority.max,
      category: AndroidNotificationCategory.reminder,
      visibility: NotificationVisibility.public,
      playSound: true,
      enableVibration: true,
      vibrationPattern: _vibrationPattern,
      ticker: ticker,
    );
  }

  Future<void> scheduleReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledAt,
    bool promptForPermissions = false,
  }) async {
    final notificationId = _reminderNotificationId(id);
    await cancelReminder(id);

    try {
      await ensureReminderPermissions(prompt: promptForPermissions);

      final notificationsAllowed = await _areNotificationsEnabled();
      if (!notificationsAllowed) {
        AppLogger.instance.w(
          'Cannot schedule reminder $id — notification permission denied',
        );
        return;
      }

      final tzScheduled = _toTzDateTime(scheduledAt);
      final now = tz.TZDateTime.now(tz.local);
      if (!tzScheduled.isAfter(now)) {
        AppLogger.instance.w(
          'Skipping schedule for reminder $id; $tzScheduled is not after $now',
        );
        return;
      }

      final mode = await _androidScheduleMode(
        promptForExact: promptForPermissions,
      );
      final details = NotificationDetails(
        android: _androidDetails(
          channelId: _reminderChannelId,
          channelName: _reminderChannelName,
          channelDescription: 'Bill, subscription, and payment reminders',
          ticker: title,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

      await _plugin.zonedSchedule(
        notificationId,
        title,
        body,
        tzScheduled,
        details,
        androidScheduleMode: mode,
      );

      AppLogger.instance.i(
        'Scheduled reminder $id (notif=$notificationId) at $tzScheduled '
        'mode=$mode local=${tz.local.name}',
      );
    } catch (error, stackTrace) {
      AppLogger.instance.w(
        'Reminder schedule failed',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Converts a device-local [DateTime] into a [tz.TZDateTime] for scheduling.
  ///
  /// Uses the absolute instant so scheduling stays correct even if timezone
  /// database lookup failed and `tz.local` is still UTC.
  tz.TZDateTime _toTzDateTime(DateTime value) {
    final local = value.isUtc ? value.toLocal() : value;
    return tz.TZDateTime.from(local, tz.local);
  }

  Future<bool> _areNotificationsEnabled() async {
    if (kIsWeb) return true;
    if (Platform.isAndroid) {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      return await android?.areNotificationsEnabled() ?? true;
    }
    return true;
  }

  Future<void> cancelReminder(int id) async {
    try {
      await _plugin.cancel(_reminderNotificationId(id));
    } catch (error, stackTrace) {
      AppLogger.instance.w(
        'Reminder cancel failed',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> cancelAllReminders(Iterable<int> reminderIds) async {
    for (final id in reminderIds) {
      await cancelReminder(id);
    }
  }

  Future<void> showReminderNow({
    required int id,
    required String title,
    required String body,
  }) async {
    await _show(
      id: _reminderNotificationId(id),
      title: title,
      body: body,
      channelId: _reminderChannelId,
      channelName: _reminderChannelName,
    );
  }

  Future<void> showBudgetWarning({
    required int budgetId,
    required String categoryName,
    required double spent,
    required double target,
  }) async {
    await _show(
      id: budgetId * 10 + 1,
      title: 'budget_alert_warning_title'.tr,
      body: 'budget_alert_warning_body'.trParams({
        'category': categoryName,
        'spent': spent.toStringAsFixed(0),
        'target': target.toStringAsFixed(0),
      }),
    );
  }

  Future<void> showBudgetExceeded({
    required int budgetId,
    required String categoryName,
    required double spent,
    required double target,
  }) async {
    await _show(
      id: budgetId * 10 + 2,
      title: 'budget_alert_exceeded_title'.tr,
      body: 'budget_alert_exceeded_body'.trParams({
        'category': categoryName,
        'spent': spent.toStringAsFixed(0),
        'target': target.toStringAsFixed(0),
      }),
    );
  }

  Future<void> showEnvelopeWarning({
    required int envelopeId,
    required double spent,
    required double target,
  }) async {
    await _show(
      id: 500000 + envelopeId * 10 + 1,
      title: 'envelope_alert_warning_title'.tr,
      body: 'envelope_alert_warning_body'.trParams({
        'spent': spent.toStringAsFixed(0),
        'target': target.toStringAsFixed(0),
      }),
    );
  }

  Future<void> showEnvelopeExceeded({
    required int envelopeId,
    required double spent,
    required double target,
  }) async {
    await _show(
      id: 500000 + envelopeId * 10 + 2,
      title: 'envelope_alert_exceeded_title'.tr,
      body: 'envelope_alert_exceeded_body'.trParams({
        'spent': spent.toStringAsFixed(0),
        'target': target.toStringAsFixed(0),
      }),
    );
  }

  Future<void> showRecurringGenerated({required int count}) async {
    await _show(
      id: 9000 + count,
      title: 'recurring_alert_title'.tr,
      body: 'recurring_alert_body'.trParams({'count': count.toString()}),
      channelId: _recurringChannelId,
      channelName: _recurringChannelName,
    );
  }

  Future<void> showUpdateDownloadProgress({
    required String version,
    required int progress,
    required int maxProgress,
    bool paused = false,
    bool indeterminate = false,
  }) async {
    final clamped = progress.clamp(0, maxProgress <= 0 ? 100 : maxProgress);
    final title = paused
        ? 'update_notification_paused_title'.tr
        : 'update_notification_downloading_title'.tr;
    final body = (paused
            ? 'update_notification_paused_body'
            : 'update_notification_downloading_body')
        .trParams({
      'version': version,
      'percent': '$clamped',
    });

    try {
      await _plugin.show(
        updateNotificationId,
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _updateProgressChannelId,
            _updateProgressChannelName,
            channelDescription: 'APK download progress',
            importance: Importance.low,
            priority: Priority.low,
            category: AndroidNotificationCategory.progress,
            showProgress: true,
            maxProgress: maxProgress <= 0 ? 100 : maxProgress,
            progress: clamped,
            indeterminate: indeterminate || maxProgress <= 0,
            ongoing: true,
            autoCancel: false,
            onlyAlertOnce: true,
            playSound: false,
            enableVibration: false,
            silent: true,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: false,
            presentBadge: false,
            presentSound: false,
          ),
        ),
        payload: updateOpenPayload,
      );
    } catch (error, stackTrace) {
      AppLogger.instance.w(
        'Update progress notification failed',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> showUpdateReadyToInstall({required String version}) async {
    try {
      await _plugin.show(
        updateNotificationId,
        'update_notification_ready_title'.tr,
        'update_notification_ready_body'.trParams({'version': version}),
        NotificationDetails(
          android: AndroidNotificationDetails(
            _updateCompleteChannelId,
            _updateCompleteChannelName,
            channelDescription: 'Update downloaded and ready to install',
            importance: Importance.high,
            priority: Priority.high,
            category: AndroidNotificationCategory.status,
            ongoing: false,
            autoCancel: true,
            playSound: true,
            enableVibration: true,
            vibrationPattern: _vibrationPattern,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: updateInstallPayload,
      );
    } catch (error, stackTrace) {
      AppLogger.instance.w(
        'Update ready notification failed',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> showUpdateDownloadFailed({required String version}) async {
    try {
      await _plugin.show(
        updateNotificationId,
        'update_notification_failed_title'.tr,
        'update_notification_failed_body'.trParams({'version': version}),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _updateCompleteChannelId,
            _updateCompleteChannelName,
            channelDescription: 'Update downloaded and ready to install',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
            category: AndroidNotificationCategory.error,
            ongoing: false,
            autoCancel: true,
            playSound: false,
            enableVibration: false,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: false,
            presentSound: false,
          ),
        ),
        payload: updateOpenPayload,
      );
    } catch (error, stackTrace) {
      AppLogger.instance.w(
        'Update failed notification failed',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> cancelUpdateDownload() async {
    try {
      await _plugin.cancel(updateNotificationId);
    } catch (error, stackTrace) {
      AppLogger.instance.w(
        'Update notification cancel failed',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _show({
    required int id,
    required String title,
    required String body,
    String channelId = _budgetChannelId,
    String channelName = _budgetChannelName,
  }) async {
    try {
      final details = NotificationDetails(
        android: _androidDetails(
          channelId: channelId,
          channelName: channelName,
          ticker: title,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );
      await _plugin.show(id, title, body, details);
      AppLogger.instance.i('Showed notification id=$id title=$title');
    } catch (error, stackTrace) {
      AppLogger.instance.w(
        'Notification failed',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}
