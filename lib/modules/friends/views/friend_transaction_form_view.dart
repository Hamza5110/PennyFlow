import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/friend_constants.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/receipt_image_picker_section.dart';
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
            Obx(
              () => ReceiptImagePickerSection(
                title: 'friends_receipts'.tr,
                imagePaths: controller.imagePaths.toList(),
                onAddGallery: controller.addFromGallery,
                onAddCamera: controller.addFromCamera,
                onRemove: (index) => controller.removeImage(index),
                galleryLabel: 'expense_gallery'.tr,
                cameraLabel: 'expense_camera'.tr,
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
