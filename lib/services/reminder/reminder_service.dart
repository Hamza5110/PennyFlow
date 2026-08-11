import 'package:get/get.dart';

import '../../core/base/base_service.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/friend_constants.dart';
import '../../core/constants/reminder_constants.dart';
import '../../core/constants/storage_keys.dart';
import '../../core/constants/validation_constants.dart';
import '../../core/errors/app_exception.dart';
import '../../core/errors/service_result.dart';
import '../../core/extensions/date_extensions.dart';
import '../../data/models/friend_transaction.dart';
import '../../data/models/reminder.dart';
import '../../data/models/reminder/reminder_input.dart';
import '../../data/models/reminder/reminder_list_item.dart';
import '../../data/repositories/friend_repository.dart';
import '../../data/repositories/reminder_repository.dart';
import '../notification/notification_service.dart';
import '../settings/settings_service.dart';
import '../storage/local_storage_service.dart';

class ReminderService extends GetxService with BaseService {
  ReminderService(
    this._reminders,
    this._friends,
    this._notifications,
    this._settings,
    this._storage,
  );

  final ReminderRepository _reminders;
  final FriendRepository _friends;
  final NotificationService _notifications;
  final SettingsService _settings;
  final LocalStorageService _storage;

  int? get _profileId => _settings.activeProfileId;

  bool get _alertsAllowed =>
      _settings.notificationsEnabled.value &&
      _settings.reminderAlertsEnabled.value;

  Future<List<ReminderListItem>> listReminders({bool includeCompleted = false}) async {
    final profileId = _profileId;
    if (profileId == null) return [];

    final all = await _reminders.findActiveByProfile(profileId);
    final now = DateTime.now();
    final items = <ReminderListItem>[];

    for (final reminder in all) {
      if (!includeCompleted && reminder.isCompleted) continue;
      items.add(
        ReminderListItem(
          reminder: reminder,
          subtitle: _subtitleFor(reminder),
          isOverdue: !reminder.isCompleted && reminder.scheduledAt.isBefore(now),
        ),
      );
    }

    items.sort((a, b) {
      if (a.reminder.isCompleted != b.reminder.isCompleted) {
        return a.reminder.isCompleted ? 1 : -1;
      }
      return a.reminder.scheduledAt.compareTo(b.reminder.scheduledAt);
    });

    return items;
  }

  Future<Reminder?> getById(int id) async {
    final profileId = _profileId;
    if (profileId == null) return null;
    final reminder = await _reminders.findById(id);
    if (reminder == null ||
        reminder.profileId != profileId ||
        reminder.isDeleted) {
      return null;
    }
    return reminder;
  }

  Future<ServiceResult<Reminder>> create(ReminderInput input) async {
    return guard(() async {
      _validateInput(input);
      final profileId = _requireProfileId();

      final reminder = Reminder()
        ..type = input.type
        ..title = input.title.trim()
        ..notes = input.notes?.trim().isEmpty == true ? null : input.notes?.trim()
        ..scheduledAt = input.scheduledAt
        ..linkedFriendTransactionId = input.linkedFriendTransactionId
        ..profileId = profileId
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now();

      final id = await _reminders.put(reminder);
      reminder.id = id;
      await _clearNotifiedFlag(reminder);
      await _scheduleIfNeeded(
        reminder,
        notifyIfOverdue: true,
        promptForPermissions: true,
      );
      return reminder;
    });
  }

  Future<ServiceResult<Reminder>> update(int id, ReminderInput input) async {
    return guard(() async {
      _validateInput(input);
      final profileId = _requireProfileId();
      final existing = await _getOwnedReminder(id, profileId);

      existing
        ..type = input.type
        ..title = input.title.trim()
        ..notes = input.notes?.trim().isEmpty == true ? null : input.notes?.trim()
        ..scheduledAt = input.scheduledAt
        ..linkedFriendTransactionId = input.linkedFriendTransactionId
        ..isCompleted = false
        ..updatedAt = DateTime.now();

      await _reminders.put(existing);
      await _clearNotifiedFlag(existing);
      await _scheduleIfNeeded(
        existing,
        notifyIfOverdue: true,
        promptForPermissions: true,
      );
      return existing;
    });
  }

  Future<ServiceResult<void>> dismiss(int id) async {
    return guardVoid(() async {
      final profileId = _requireProfileId();
      final reminder = await _getOwnedReminder(id, profileId);
      reminder
        ..isCompleted = true
        ..updatedAt = DateTime.now();
      await _reminders.put(reminder);
      await _notifications.cancelReminder(reminder.id);
      await _markNotified(reminder);
    });
  }

  Future<ServiceResult<void>> snooze(int id, {Duration duration = const Duration(hours: 1)}) async {
    return guardVoid(() async {
      final profileId = _requireProfileId();
      final reminder = await _getOwnedReminder(id, profileId);
      await _clearNotifiedFlag(reminder);
      reminder
        ..scheduledAt = DateTime.now().add(duration)
        ..isCompleted = false
        ..updatedAt = DateTime.now();
      await _reminders.put(reminder);
      await _clearNotifiedFlag(reminder);
      await _scheduleIfNeeded(
        reminder,
        notifyIfOverdue: true,
        promptForPermissions: true,
      );
    });
  }

  Future<ServiceResult<void>> delete(int id) async {
    return guardVoid(() async {
      final profileId = _requireProfileId();
      final reminder = await _getOwnedReminder(id, profileId);
      reminder
        ..isDeleted = true
        ..deletedAt = DateTime.now()
        ..updatedAt = DateTime.now();
      await _reminders.put(reminder);
      await _notifications.cancelReminder(reminder.id);
      await _clearNotifiedFlag(reminder);
    });
  }

  /// Soft-deletes and cancels the reminder linked to a friend transaction.
  Future<void> deleteByLinkedFriendTransaction(int transactionId) async {
    final profileId = _profileId;
    if (profileId == null) return;

    final existing = await _reminders.findByLinkedFriendTransaction(
      profileId,
      transactionId,
    );
    if (existing == null) return;

    existing
      ..isDeleted = true
      ..deletedAt = DateTime.now()
      ..updatedAt = DateTime.now();
    await _reminders.put(existing);
    await _notifications.cancelReminder(existing.id);
    await _clearNotifiedFlag(existing);
  }

  /// Cancels OS notifications when alerts are disabled, otherwise re-schedules.
  Future<void> applyAlertPreference() async {
    if (!_alertsAllowed) {
      await cancelAllScheduled();
      return;
    }
    // User explicitly turned reminder alerts on — ask now.
    await _notifications.ensureReminderPermissions(prompt: true);
    await rescheduleAll();
  }

  /// Cancels every pending reminder notification for the active profile.
  Future<void> cancelAllScheduled() async {
    final profileId = _profileId;
    if (profileId == null) return;

    final pending = await _reminders.findPendingByProfile(profileId);
    await _notifications.cancelAllReminders(pending.map((r) => r.id));
  }

  /// Re-schedules pending reminders and delivers any missed overdue alerts once.
  Future<void> rescheduleAll() async {
    if (!_alertsAllowed) {
      await cancelAllScheduled();
      return;
    }
    final profileId = _profileId;
    if (profileId == null) return;

    final pending = await _reminders.findPendingByProfile(profileId);
    for (final reminder in pending) {
      // Catch up overdue reminders that the OS never delivered (exact alarm
      // denied / app killed). Only fires once per scheduled time.
      await _scheduleIfNeeded(reminder, notifyIfOverdue: true);
    }
  }

  /// Auto-creates or updates a friend payment reminder (FR-135).
  Future<void> syncFriendTransaction(FriendTransaction transaction) async {
    final profileId = _profileId;
    if (profileId == null || transaction.profileId != profileId) return;

    final existing = await _reminders.findByLinkedFriendTransaction(
      profileId,
      transaction.id,
    );

    if (transaction.isDeleted ||
        transaction.dueDate == null ||
        transaction.status == FriendTransactionStatus.completed) {
      if (existing != null) {
        await dismiss(existing.id);
      }
      return;
    }

    final friend = await _friends.findById(transaction.friendId);
    final friendName = friend?.name ?? 'Friend';
    final scheduledAt = _reminderTimeForDueDate(transaction.dueDate!);
    final title = 'reminder_friend_payment_title'.trParams({
      'friend': friendName,
    });

    if (existing != null) {
      final timeChanged = existing.scheduledAt != scheduledAt;
      existing
        ..title = title
        ..scheduledAt = scheduledAt
        ..isCompleted = false
        ..updatedAt = DateTime.now();
      await _reminders.put(existing);
      if (timeChanged) await _clearNotifiedFlag(existing);
      await _scheduleIfNeeded(existing, notifyIfOverdue: true);
      return;
    }

    final reminder = Reminder()
      ..type = ReminderTypes.friendPaymentDue
      ..title = title
      ..scheduledAt = scheduledAt
      ..linkedFriendTransactionId = transaction.id
      ..profileId = profileId
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now();

    final id = await _reminders.put(reminder);
    reminder.id = id;
    await _scheduleIfNeeded(reminder, notifyIfOverdue: true);
  }

  DateTime _reminderTimeForDueDate(DateTime dueDate) {
    return DateTime(dueDate.year, dueDate.month, dueDate.day, 9);
  }

  Future<void> _scheduleIfNeeded(
    Reminder reminder, {
    required bool notifyIfOverdue,
    bool promptForPermissions = false,
  }) async {
    if (!_alertsAllowed || reminder.isCompleted) {
      await _notifications.cancelReminder(reminder.id);
      return;
    }

    if (!reminder.scheduledAt.isAfter(DateTime.now())) {
      await _notifications.cancelReminder(reminder.id);
      if (notifyIfOverdue) {
        if (promptForPermissions) {
          await _notifications.ensureReminderPermissions(prompt: true);
        }
        await _notifyOverdueOnce(reminder);
      }
      return;
    }

    await _notifications.scheduleReminder(
      id: reminder.id,
      title: reminder.title,
      body: reminder.notes ?? _typeLabel(reminder.type),
      scheduledAt: reminder.scheduledAt,
      promptForPermissions: promptForPermissions,
    );
  }

  Future<void> _notifyOverdueOnce(Reminder reminder) async {
    if (_wasNotified(reminder)) return;

    await _notifications.showReminderNow(
      id: reminder.id,
      title: reminder.title,
      body: reminder.notes ?? _typeLabel(reminder.type),
    );
    await _markNotified(reminder);
  }

  String _notifiedKey(Reminder reminder) =>
      '${StorageKeys.reminderNotifiedPrefix}'
      '${reminder.id}_${reminder.scheduledAt.millisecondsSinceEpoch}';

  bool _wasNotified(Reminder reminder) =>
      _storage.getBoolOr(_notifiedKey(reminder), false);

  Future<void> _markNotified(Reminder reminder) =>
      _storage.setBool(_notifiedKey(reminder), true);

  Future<void> _clearNotifiedFlag(Reminder reminder) =>
      _storage.remove(_notifiedKey(reminder));

  String _subtitleFor(Reminder reminder) {
    final type = _typeLabel(reminder.type);
    final when = reminder.scheduledAt.format('dd MMM yyyy · hh:mm a');
    return '$type · $when';
  }

  String _typeLabel(String type) => 'reminder_type_$type'.tr;

  void _validateInput(ReminderInput input) {
    if (input.title.trim().isEmpty) {
      throw const ValidationException(message: 'Title is required');
    }
    if (input.title.trim().length > AppConstants.maxNameLength) {
      throw const ValidationException(message: 'Title is too long');
    }
    if (!ReminderTypes.all.contains(input.type)) {
      throw const ValidationException(message: 'Invalid reminder type');
    }
    if (input.notes != null &&
        input.notes!.trim().length > ValidationConstants.maxNotesLength) {
      throw const ValidationException(message: 'Notes are too long');
    }
  }

  Future<Reminder> _getOwnedReminder(int id, int profileId) async {
    final reminder = await _reminders.findById(id);
    if (reminder == null ||
        reminder.profileId != profileId ||
        reminder.isDeleted) {
      throw const NotFoundException(message: 'Reminder not found');
    }
    return reminder;
  }

  int _requireProfileId() {
    final profileId = _profileId;
    if (profileId == null) {
      throw const ValidationException(message: 'No active profile');
    }
    return profileId;
  }
}
