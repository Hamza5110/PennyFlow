import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/receipt_image_picker_section.dart';
import '../controllers/expense_form_controller.dart';

class ExpenseFormView extends GetView<ExpenseFormController> {
  const ExpenseFormView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: controller.isEditing ? 'expense_edit'.tr : 'expense_add'.tr,
      isLoading: false,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              controller: controller.amountController,
              label: 'expense_amount'.tr,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              prefixIcon: Icons.payments_outlined,
            ),
            const SizedBox(height: 16),
            Obx(
              () => DropdownButtonFormField<int>(
                initialValue: controller.selectedCategoryId.value,
                decoration: InputDecoration(labelText: 'expense_category'.tr),
                items: controller.categories
                    .map(
                      (c) => DropdownMenuItem(
                        value: c.id,
                        child: Text(c.name),
                      ),
                    )
                    .toList(),
                onChanged: (v) => controller.selectedCategoryId.value = v,
              ),
            ),
            const SizedBox(height: 16),
            Obx(
              () => DropdownButtonFormField<int>(
                initialValue: controller.selectedAccountId.value,
                decoration: InputDecoration(labelText: 'expense_account'.tr),
                items: controller.accounts
                    .map(
                      (a) => DropdownMenuItem(
                        value: a.id,
                        child: Text(a.name),
                      ),
                    )
                    .toList(),
                onChanged: (v) => controller.selectedAccountId.value = v,
              ),
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
                      onPressed: () => controller.pickTime(context),
                      icon: const Icon(Icons.access_time_rounded),
                      label: Text(controller.selectedTime.value.format(context)),
                    ),
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
            const SizedBox(height: 16),
            AppTextField(
              controller: controller.locationController,
              label: 'expense_location'.tr,
              prefixIcon: Icons.place_outlined,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: controller.tagsController,
              label: 'expense_tags_hint'.tr,
            ),
            const SizedBox(height: 16),
            Obx(
              () => ReceiptImagePickerSection(
                title: 'expense_receipts'.tr,
                imagePaths: controller.imagePaths.toList(),
                onAddGallery: controller.addFromGallery,
                onAddCamera: controller.addFromCamera,
                onRemove: (index) => controller.removeImage(index),
              ),
            ),
            const SizedBox(height: 24),
            Obx(
              () => AppButton(
                label: 'common_save'.tr,
                onPressed: controller.save,
                isLoading: controller.isLoading.value,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
