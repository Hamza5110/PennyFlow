import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../services/settings/settings_service.dart';
import '../controllers/repayment_form_controller.dart';

class RepaymentFormView extends GetView<RepaymentFormController> {
  const RepaymentFormView({super.key});

  @override
  Widget build(BuildContext context) {
    final currency = Get.find<SettingsService>().currencyCode.value;

    return AppScaffold(
      title: 'friends_add_repayment'.tr,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Obx(
              () => Text(
                'friends_remaining'.trParams({
                  'amount': AppFormatters.currency(
                    controller.remainingBalance.value,
                    currencyCode: currency,
                  ),
                }),
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
            Obx(
              () => OutlinedButton.icon(
                onPressed: () => controller.pickDate(context),
                icon: const Icon(Icons.calendar_today_outlined),
                label: Text(
                  '${controller.selectedDate.value.day}/${controller.selectedDate.value.month}/${controller.selectedDate.value.year}',
                ),
              ),
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: controller.noteController,
              label: 'friends_notes'.tr,
              prefixIcon: Icons.notes_outlined,
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            Text('friends_receipts'.tr, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Obx(
              () => Wrap(
                spacing: 8,
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
