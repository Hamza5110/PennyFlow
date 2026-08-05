import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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

  static const String _budgetChannelId = 'penny_flow_budget_alerts';
  static const String _budgetChannelName = 'Budget Alerts';
  static const String _recurringChannelId = 'penny_flow_recurring';
  static const String _recurringChannelName = 'Recurring Transactions';
  static const String _reminderChannelId = 'penny_flow_reminders';
  static const String _reminderChannelName = 'Reminders';

  static int _reminderNotificationId(int reminderId) => 10000 + reminderId;

  Future<NotificationService> init() async {
    tz_data.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwin = DarwinInitializationSettings();
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
      Importance.high,
    );

    return this;
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
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> scheduleReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledAt,
  }) async {
    final notificationId = _reminderNotificationId(id);
    await cancelReminder(id);

    try {
      final tzScheduled = tz.TZDateTime.from(scheduledAt, tz.local);
      final details = NotificationDetails(
        android: AndroidNotificationDetails(
          _reminderChannelId,
          _reminderChannelName,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      );

      await _plugin.zonedSchedule(
        notificationId,
        title,
        body,
        tzScheduled,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } catch (error, stackTrace) {
      AppLogger.instance.w(
        'Reminder schedule failed',
        error: error,
        stackTrace: stackTrace,
      );
    }
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
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      );
      await _plugin.show(id, title, body, details);
    } catch (error, stackTrace) {
      AppLogger.instance.w(
        'Notification failed',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}
