import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_text_field.dart';
import '../controllers/category_form_controller.dart';
import '../widgets/category_pickers.dart';

class CategoryFormView extends GetView<CategoryFormController> {
  const CategoryFormView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppScaffold(
      title: controller.isEditing ? 'categories_edit'.tr : 'categories_add'.tr,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              controller: controller.nameController,
              label: 'categories_name'.tr,
              prefixIcon: Icons.label_outline_rounded,
            ),
            const SizedBox(height: 24),
            Text('categories_color'.tr, style: theme.textTheme.titleSmall),
            const SizedBox(height: 12),
            Obx(
              () => CategoryColorPicker(
                selectedHex: controller.selectedColorHex.value,
                onSelected: controller.selectColor,
              ),
            ),
            const SizedBox(height: 24),
            Text('categories_icon'.tr, style: theme.textTheme.titleSmall),
            const SizedBox(height: 12),
            Obx(
              () => CategoryIconPicker(
                selectedKey: controller.selectedIconKey.value,
                colorHex: controller.selectedColorHex.value,
                onSelected: controller.selectIcon,
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
