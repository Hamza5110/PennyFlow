import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_text_field.dart';
import '../controllers/friend_form_controller.dart';

class FriendFormView extends GetView<FriendFormController> {
  const FriendFormView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: controller.isEditing ? 'friends_edit'.tr : 'friends_add'.tr,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              controller: controller.nameController,
              label: 'friends_name'.tr,
              prefixIcon: Icons.person_outline_rounded,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: controller.phoneController,
              label: 'friends_phone'.tr,
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 24),
            AppButton(label: 'common_save'.tr, onPressed: controller.save),
          ],
        ),
      ),
    );
  }
}
