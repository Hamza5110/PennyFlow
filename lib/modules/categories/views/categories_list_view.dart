import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_loading_indicator.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../controllers/categories_list_controller.dart';
import '../widgets/category_delete_dialog.dart';

class CategoriesListView extends GetView<CategoriesListController> {
  const CategoriesListView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'categories_title'.tr,
      body: Obx(() {
        if (controller.isLoading.value && controller.items.isEmpty) {
          return AppLoadingIndicator(message: 'common_loading'.tr);
        }
        if (controller.items.isEmpty) {
          return AppEmptyState(
            title: 'categories_empty_title'.tr,
            message: 'categories_empty_message'.tr,
            icon: Icons.category_outlined,
            actionLabel: 'categories_add'.tr,
            onAction: controller.openAdd,
          );
        }

        return RefreshIndicator(
          onRefresh: controller.loadCategories,
          child: ListView.separated(
            itemCount: controller.items.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final category = controller.items[index];
              final usage = controller.usageCounts[category.id] ?? 0;
              return CategoryListTile(
                category: category,
                usageCount: usage,
                onTap: () => controller.openEdit(category),
                onDelete: () => controller.deleteCategory(category),
              );
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.openAdd,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}
