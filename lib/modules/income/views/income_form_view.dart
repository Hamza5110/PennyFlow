import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_dropdown.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/receipt_image_picker_section.dart';
import '../controllers/income_form_controller.dart';

class IncomeFormView extends GetView<IncomeFormController> {
  const IncomeFormView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: controller.isEditing ? 'income_edit'.tr : 'income_add'.tr,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              controller: controller.amountController,
              label: 'income_amount'.tr,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              prefixIcon: Icons.payments_outlined,
            ),
            const SizedBox(height: 16),
            Obx(
              () => AppDropdown<String>(
                value: controller.useCustomSource.value
                    ? controller.sourceOptions.last.key
                    : controller.selectedSourceKey.value,
                label: 'income_source'.tr,
                items: controller.sourceOptions.map((option) => option.key).toList(),
                itemLabel: (key) => controller.sourceOptions
                    .firstWhere((option) => option.key == key)
                    .label,
                onChanged: controller.onSourceChanged,
              ),
            ),
            Obx(
              () => controller.useCustomSource.value
                  ? Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: AppTextField(
                        controller: controller.customSourceController,
                        label: 'income_custom_source'.tr,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            const SizedBox(height: 16),
            Obx(
              () => AppDropdown<int>(
                value: controller.selectedAccountId.value,
                label: 'income_account'.tr,
                items: controller.accounts.map((a) => a.id).toList(),
                itemLabel: (id) =>
                    controller.accounts.firstWhere((a) => a.id == id).name,
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
              label: 'income_notes'.tr,
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Obx(
              () => ReceiptImagePickerSection(
                title: 'income_images'.tr,
                imagePaths: controller.imagePaths.toList(),
                onAddGallery: controller.addFromGallery,
                onAddCamera: controller.addFromCamera,
                onRemove: (index) => controller.removeImage(index),
                galleryLabel: 'income_gallery'.tr,
                cameraLabel: 'income_camera'.tr,
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
