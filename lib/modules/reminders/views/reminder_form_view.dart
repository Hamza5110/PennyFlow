import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/reminder_constants.dart';
import '../../../core/extensions/date_extensions.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_dropdown.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_text_field.dart';
import '../controllers/reminder_form_controller.dart';

class ReminderFormView extends GetView<ReminderFormController> {
  const ReminderFormView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AppScaffold(
        title: controller.isEditing ? 'reminders_edit'.tr : 'reminders_add'.tr,
        isLoading: controller.isLoading.value,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppDropdown<String>(
                items: ReminderTypes.manualTypes,
                itemLabel: (type) => 'reminder_type_$type'.tr,
                value: controller.type.value,
                label: 'reminders_type'.tr,
                enabled: !controller.isEditing,
                onChanged: controller.isEditing
                    ? null
                    : (value) {
                        if (value != null) controller.type.value = value;
                      },
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: controller.titleController,
                label: 'reminders_title_label'.tr,
                prefixIcon: Icons.title_rounded,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => controller.pickDate(context),
                      icon: const Icon(Icons.calendar_today_outlined),
                      label: Text(controller.scheduledAt.value.format('dd MMM yyyy')),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => controller.pickTime(context),
                      icon: const Icon(Icons.access_time_rounded),
                      label: Text(controller.scheduledAt.value.format('hh:mm a')),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: controller.notesController,
                label: 'expense_notes'.tr,
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              AppButton(
                label: 'common_save'.tr,
                isLoading: controller.isLoading.value,
                onPressed: controller.save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
