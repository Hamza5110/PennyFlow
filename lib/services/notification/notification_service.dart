import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

import '../../core/base/base_service.dart';
import '../../core/logging/app_logger.dart';

/// Local notifications for budget alerts (FR-081, FR-082).
class NotificationService extends GetxService with BaseService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'penny_flow_budget_alerts';
  static const String _channelName = 'Budget Alerts';

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
      _channelId,
      _channelName,
      description: 'Budget warning and exceeded alerts',
      importance: Importance.high,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

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
  }) async {
    try {
      const details = NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
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
}
