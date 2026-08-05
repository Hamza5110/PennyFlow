import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/widgets/app_button.dart';
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
              () => DropdownButtonFormField<String>(
                initialValue: controller.selectedType.value,
                decoration: InputDecoration(labelText: 'accounts_type'.tr),
                items: controller.typeOptions
                    .map(
                      (option) => DropdownMenuItem(
                        value: option.key,
                        child: Text(option.label),
                      ),
                    )
                    .toList(),
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
