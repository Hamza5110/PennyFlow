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

  static const String _budgetChannelId = 'penny_flow_budget_alerts_v2';
  static const String _budgetChannelName = 'Budget Alerts';
  static const String _recurringChannelId = 'penny_flow_recurring_v2';
  static const String _recurringChannelName = 'Recurring Transactions';
  static const String _reminderChannelId = 'penny_flow_reminders_v3';
  static const String _reminderChannelName = 'Reminders';

  /// delay, vibrate, pause, vibrate (ms) — noticeable even in silent/vibrate mode.
  static final Int64List _vibrationPattern =
      Int64List.fromList(<int>[0, 500, 200, 500]);

  static int _reminderNotificationId(int reminderId) => 10000 + reminderId;

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

    await _plugin.initialize(initSettings);

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

    // Do not request notification/alarm permissions here — ask only when the
    // user opts into reminders (create/enable), so startup stays quiet.
    return this;
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
    Importance importance,
  ) async {
    final channel = AndroidNotificationChannel(
      id,
      name,
      description: description,
      importance: importance,
      playSound: true,
      enableVibration: true,
      vibrationPattern: _vibrationPattern,
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

  Future<void> showRecurringGenerated({required int count}) async {
    await _show(
      id: 9000 + count,
      title: 'recurring_alert_title'.tr,
      body: 'recurring_alert_body'.trParams({'count': count.toString()}),
      channelId: _recurringChannelId,
      channelName: _recurringChannelName,
    );
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
