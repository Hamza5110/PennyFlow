import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/category_icons.dart';
import '../../../data/models/category.dart';

class CategoryDeleteDialog {
  CategoryDeleteDialog._();

  static Future<int?> show({
    required String categoryName,
    required int usageCount,
    required List<Category> alternatives,
  }) {
    return Get.dialog<int>(
      _CategoryDeleteDialogBody(
        categoryName: categoryName,
        usageCount: usageCount,
        alternatives: alternatives,
      ),
    );
  }
}

class _CategoryDeleteDialogBody extends StatefulWidget {
  const _CategoryDeleteDialogBody({
    required this.categoryName,
    required this.usageCount,
    required this.alternatives,
  });

  final String categoryName;
  final int usageCount;
  final List<Category> alternatives;

  @override
  State<_CategoryDeleteDialogBody> createState() =>
      _CategoryDeleteDialogBodyState();
}

class _CategoryDeleteDialogBodyState extends State<_CategoryDeleteDialogBody> {
  late int _selectedId;

  @override
  void initState() {
    super.initState();
    _selectedId = widget.alternatives.first.id;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('categories_reassign_title'.tr),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'categories_reassign_message'.trParams({
              'name': widget.categoryName,
              'count': widget.usageCount.toString(),
            }),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<int>(
            initialValue: _selectedId,
            decoration: InputDecoration(labelText: 'categories_reassign_to'.tr),
            items: widget.alternatives
                .map(
                  (category) => DropdownMenuItem(
                    value: category.id,
                    child: Text(category.name),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) setState(() => _selectedId = value);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back<void>(),
          child: Text('common_cancel'.tr),
        ),
        FilledButton(
          onPressed: () => Get.back(result: _selectedId),
          child: Text('categories_reassign_confirm'.tr),
        ),
      ],
    );
  }
}

class CategoryListTile extends StatelessWidget {
  const CategoryListTile({
    super.key,
    required this.category,
    required this.usageCount,
    required this.onTap,
    required this.onDelete,
  });

  final Category category;
  final int usageCount;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = CategoryIcons.parseColor(category.colorHex);

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.15),
        child: Icon(
          CategoryIcons.fromKey(category.iconKey),
          color: color,
        ),
      ),
      title: Text(category.name),
      subtitle: Text(
        category.isDefault
            ? 'categories_default_badge'.tr
            : 'categories_custom_badge'.tr,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (usageCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(
                'categories_usage_count'.trParams({'count': '$usageCount'}),
                style: theme.textTheme.bodySmall,
              ),
            ),
          if (!category.isDefault)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: onDelete,
            ),
        ],
      ),
    );
  }
}
