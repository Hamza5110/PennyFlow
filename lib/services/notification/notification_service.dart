import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

import '../../core/base/base_service.dart';
import '../../core/logging/app_logger.dart';

/// Local notifications for budget alerts (FR-081, FR-082).
class NotificationService extends GetxService with BaseService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String _budgetChannelId = 'penny_flow_budget_alerts';
  static const String _budgetChannelName = 'Budget Alerts';
  static const String _recurringChannelId = 'penny_flow_recurring';
  static const String _recurringChannelName = 'Recurring Transactions';

  Future<NotificationService> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwin = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: android,
      iOS: darwin,
      macOS: darwin,
    );

    await _plugin.initialize(initSettings);

    const channel = AndroidNotificationChannel(
      _budgetChannelId,
      _budgetChannelName,
      description: 'Budget warning and exceeded alerts',
      importance: Importance.high,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    const recurringChannel = AndroidNotificationChannel(
      _recurringChannelId,
      _recurringChannelName,
      description: 'Recurring transaction auto-generation alerts',
      importance: Importance.defaultImportance,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(recurringChannel);

    return this;
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
        iOS: DarwinNotificationDetails(),
      );
      await _plugin.show(id, title, body, details);
    } catch (error, stackTrace) {
      AppLogger.instance.w(
        'Budget notification failed',
        error: error,
        stackTrace: stackTrace,
      );
    }
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
}
