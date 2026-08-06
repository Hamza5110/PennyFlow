import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_dropdown.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_text_field.dart';
import '../controllers/account_form_controller.dart';

class AccountFormView extends GetView<AccountFormController> {
  const AccountFormView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: controller.isEditing ? 'accounts_edit'.tr : 'accounts_add'.tr,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              controller: controller.nameController,
              label: 'accounts_name'.tr,
              prefixIcon: Icons.account_balance_wallet_outlined,
            ),
            const SizedBox(height: 16),
            Obx(
              () => AppDropdown<String>(
                value: controller.selectedType.value,
                label: 'accounts_type'.tr,
                items: controller.typeOptions.map((option) => option.key).toList(),
                itemLabel: (key) => controller.typeOptions
                    .firstWhere((option) => option.key == key)
                    .label,
                onChanged: controller.onTypeChanged,
              ),
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: controller.openingBalanceController,
              label: 'accounts_opening_balance'.tr,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              prefixIcon: Icons.savings_outlined,
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
