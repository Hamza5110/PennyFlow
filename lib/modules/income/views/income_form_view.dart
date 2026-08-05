import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_text_field.dart';
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
              () => DropdownButtonFormField<String>(
                initialValue: controller.useCustomSource.value
                    ? controller.sourceOptions.last.key
                    : controller.selectedSourceKey.value,
                decoration: InputDecoration(labelText: 'income_source'.tr),
                items: controller.sourceOptions
                    .map(
                      (option) => DropdownMenuItem(
                        value: option.key,
                        child: Text(option.label),
                      ),
                    )
                    .toList(),
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
              () => DropdownButtonFormField<int>(
                initialValue: controller.selectedAccountId.value,
                decoration: InputDecoration(labelText: 'income_account'.tr),
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
              label: 'income_notes'.tr,
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Text('income_images'.tr, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: controller.addFromGallery,
                  icon: const Icon(Icons.photo_library_outlined),
                  label: Text('income_gallery'.tr),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: controller.addFromCamera,
                  icon: const Icon(Icons.photo_camera_outlined),
                  label: Text('income_camera'.tr),
                ),
              ],
            ),
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
                            width: 72,
                            height: 72,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: IconButton(
                            icon: const Icon(Icons.close_rounded, size: 18),
                            onPressed: () => controller.removeImage(i),
                          ),
                        ),
                      ],
                    ),
                ],
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
