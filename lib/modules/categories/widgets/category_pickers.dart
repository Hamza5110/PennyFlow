import 'package:flutter/material.dart';

import '../../../core/utils/category_icons.dart';

class CategoryColorPicker extends StatelessWidget {
  const CategoryColorPicker({
    super.key,
    required this.selectedHex,
    required this.onSelected,
  });

  final String selectedHex;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final hex in CategoryIcons.colorPalette)
          GestureDetector(
            onTap: () => onSelected(hex),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: CategoryIcons.parseColor(hex),
                shape: BoxShape.circle,
                border: Border.all(
                  color: selectedHex == hex
                      ? Theme.of(context).colorScheme.onSurface
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              child: selectedHex == hex
                  ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                  : null,
            ),
          ),
      ],
    );
  }
}

class CategoryIconPicker extends StatelessWidget {
  const CategoryIconPicker({
    super.key,
    required this.selectedKey,
    required this.colorHex,
    required this.onSelected,
  });

  final String selectedKey;
  final String colorHex;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final color = CategoryIcons.parseColor(colorHex);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: CategoryIcons.availableKeys.length,
      itemBuilder: (context, index) {
        final key = CategoryIcons.availableKeys[index];
        final isSelected = key == selectedKey;

        return InkWell(
          onTap: () => onSelected(key),
          borderRadius: BorderRadius.circular(12),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: isSelected
                  ? color.withValues(alpha: 0.2)
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? color : Colors.transparent,
                width: 2,
              ),
            ),
            child: Icon(
              CategoryIcons.fromKey(key),
              color: isSelected ? color : null,
            ),
          ),
        );
      },
    );
  }
}
