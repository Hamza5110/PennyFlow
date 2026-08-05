import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/friend_constants.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_text_field.dart';
import '../controllers/friend_transaction_form_controller.dart';

class FriendTransactionFormView extends GetView<FriendTransactionFormController> {
  const FriendTransactionFormView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: controller.isEditing
          ? 'friends_edit_transaction'.tr
          : 'friends_add_transaction'.tr,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Obx(
              () => DropdownButtonFormField<int>(
                initialValue: controller.selectedFriendId.value,
                decoration: InputDecoration(labelText: 'friends_name'.tr),
                items: controller.friendOptions
                    .map(
                      (f) => DropdownMenuItem(value: f.id, child: Text(f.name)),
                    )
                    .toList(),
                onChanged: (v) => controller.selectedFriendId.value = v,
              ),
            ),
            const SizedBox(height: 16),
            Obx(
              () => SegmentedButton<String>(
                segments: [
                  ButtonSegment(
                    value: FriendTransactionTypes.given,
                    label: Text('friends_money_given'.tr),
                    icon: const Icon(Icons.arrow_upward_rounded),
                  ),
                  ButtonSegment(
                    value: FriendTransactionTypes.received,
                    label: Text('friends_money_received'.tr),
                    icon: const Icon(Icons.arrow_downward_rounded),
                  ),
                ],
                selected: {controller.selectedType.value},
                onSelectionChanged: (s) =>
                    controller.selectedType.value = s.first,
              ),
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: controller.amountController,
              label: 'friends_amount'.tr,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              prefixIcon: Icons.payments_outlined,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Obx(
                    () => OutlinedButton.icon(
                      onPressed: () => controller.pickDate(context),
                      icon: const Icon(Icons.calendar_today_outlined),
                      label: Text(
                        '${controller.selectedDate.value.day}/${controller.selectedDate.value.month}/${controller.selectedDate.value.year}',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Obx(
                    () => OutlinedButton.icon(
                      onPressed: () => controller.pickDueDate(context),
                      icon: const Icon(Icons.event_outlined),
                      label: Text(
                        controller.selectedDueDate.value == null
                            ? 'friends_due_date'.tr
                            : '${controller.selectedDueDate.value!.day}/${controller.selectedDueDate.value!.month}/${controller.selectedDueDate.value!.year}',
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Obx(
              () => controller.selectedDueDate.value != null
                  ? Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: controller.clearDueDate,
                        child: Text('friends_clear_due_date'.tr),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: controller.notesController,
              label: 'friends_notes'.tr,
              prefixIcon: Icons.notes_outlined,
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Text('friends_receipts'.tr, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Obx(
              () => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (var i = 0; i < controller.imagePaths.length; i++)
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(controller.imagePaths[i]),
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () => controller.removeImage(i),
                          ),
                        ),
                      ],
                    ),
                  if (controller.imagePaths.length < 5)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: controller.addFromGallery,
                          icon: const Icon(Icons.photo_library_outlined),
                        ),
                        IconButton(
                          onPressed: controller.addFromCamera,
                          icon: const Icon(Icons.photo_camera_outlined),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            AppButton(label: 'common_save'.tr, onPressed: controller.save),
          ],
        ),
      ),
    );
  }
}
