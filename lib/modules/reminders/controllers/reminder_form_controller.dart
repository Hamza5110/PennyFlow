import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/base/base_controller.dart';
import '../../../core/constants/reminder_constants.dart';
import '../../../core/errors/error_handler.dart';
import '../../../data/models/reminder.dart';
import '../../../data/models/reminder/reminder_input.dart';
import '../../../services/reminder/reminder_service.dart';
import '../reminder_routes.dart';

class ReminderFormController extends BaseController {
  ReminderFormController(this._reminders);

  final ReminderService _reminders;

  final titleController = TextEditingController();
  final notesController = TextEditingController();

  final RxString type = ReminderTypes.billDue.obs;
  final Rx<DateTime> scheduledAt = DateTime.now().add(const Duration(hours: 1)).obs;

  int? _reminderId;
  bool get isEditing => _reminderId != null;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is ReminderFormArgs) _reminderId = args.reminderId;
    _bootstrap();
  }

  @override
  void onClose() {
    titleController.dispose();
    notesController.dispose();
    super.onClose();
  }

  Future<void> _bootstrap() async {
    if (_reminderId == null) return;
    await runGuarded(() async {
      final reminder = await _reminders.getById(_reminderId!);
      if (reminder == null) {
        ErrorHandler.showError('reminder_not_found'.tr);
        Get.back<void>();
        return;
      }
      _populate(reminder);
    }, showErrorSnackbar: false);
  }

  void _populate(Reminder reminder) {
    titleController.text = reminder.title;
    notesController.text = reminder.notes ?? '';
    type.value = reminder.type;
    scheduledAt.value = reminder.scheduledAt;
  }

  Future<void> pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: scheduledAt.value,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked == null) return;
    scheduledAt.value = DateTime(
      picked.year,
      picked.month,
      picked.day,
      scheduledAt.value.hour,
      scheduledAt.value.minute,
    );
  }

  Future<void> pickTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(scheduledAt.value),
    );
    if (picked == null) return;
    scheduledAt.value = DateTime(
      scheduledAt.value.year,
      scheduledAt.value.month,
      scheduledAt.value.day,
      picked.hour,
      picked.minute,
    );
  }

  ReminderInput _buildInput() {
    return ReminderInput(
      type: type.value,
      title: titleController.text.trim(),
      scheduledAt: scheduledAt.value,
      notes: notesController.text.trim(),
    );
  }

  Future<void> save() async {
    await runGuarded(() async {
      final input = _buildInput();
      final result = isEditing
          ? await _reminders.update(_reminderId!, input)
          : await _reminders.create(input);

      if (result.success) {
        ErrorHandler.popWithSuccess(
          isEditing ? 'reminder_updated'.tr : 'reminder_created'.tr,
        );
      } else if (result.userMessage != null) {
        ErrorHandler.showError(result.userMessage!);
      }
    });
  }
}
