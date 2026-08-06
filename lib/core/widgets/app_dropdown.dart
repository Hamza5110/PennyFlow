import 'package:dropdown_flutter/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Minimum item count before search is enabled automatically.
const int kAppDropdownSearchThreshold = 8;

/// Default overlay height for searchable dropdowns.
const double kAppDropdownSearchOverlayHeight = 320;

class _AppDropdownItem<T> with CustomDropdownListFilter {
  const _AppDropdownItem({required this.value, required this.label});

  final T value;
  final String label;

  @override
  bool filter(String query) =>
      label.toLowerCase().contains(query.toLowerCase());

  @override
  String toString() => label;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _AppDropdownItem<T> && other.value == value;

  @override
  int get hashCode => Object.hash(T, value);
}

/// Themed single-select dropdown backed by [DropdownFlutter].
class AppDropdown<T> extends StatelessWidget {
  const AppDropdown({
    super.key,
    required this.items,
    required this.itemLabel,
    this.value,
    this.hint,
    this.label,
    this.searchHint,
    this.onChanged,
    this.validator,
    this.enabled = true,
    this.searchable,
    this.overlayHeight,
  });

  final List<T> items;
  final String Function(T item) itemLabel;
  final T? value;
  final String? hint;
  final String? label;
  final String? searchHint;
  final ValueChanged<T?>? onChanged;
  final String? Function(T?)? validator;
  final bool enabled;

  /// When null, search is enabled automatically for lists with
  /// [kAppDropdownSearchThreshold] or more items.
  final bool? searchable;

  /// Dropdown list height when open. Defaults to [kAppDropdownSearchOverlayHeight]
  /// for searchable dropdowns.
  final double? overlayHeight;

  bool get _useSearch =>
      searchable ?? items.length >= kAppDropdownSearchThreshold;

  T? get _resolvedValue {
    if (value == null) return null;
    for (final item in items) {
      if (item == value) return item;
    }
    return null;
  }

  List<_AppDropdownItem<T>> get _wrappedItems => [
        for (final item in items)
          _AppDropdownItem(value: item, label: itemLabel(item)),
      ];

  _AppDropdownItem<T>? get _resolvedWrappedItem {
    final selected = _resolvedValue;
    for (final item in _wrappedItems) {
      if (item.value == selected) return item;
    }
    return null;
  }

  CustomDropdownDecoration _decoration(BuildContext context) {
    final theme = Theme.of(context);
    final input = theme.inputDecorationTheme;
    final colors = theme.colorScheme;
    final borderColor = colors.outline.withValues(alpha: 0.4);

    return CustomDropdownDecoration(
      closedFillColor: input.fillColor ?? colors.surfaceContainerHighest,
      expandedFillColor: colors.surface,
      closedBorder: Border.all(color: borderColor),
      expandedBorder: Border.all(color: colors.primary, width: 1.5),
      closedBorderRadius: BorderRadius.circular(12),
      expandedBorderRadius: BorderRadius.circular(12),
      closedSuffixIcon: Icon(
        Icons.keyboard_arrow_down_rounded,
        color: colors.onSurface.withValues(alpha: 0.7),
      ),
      expandedSuffixIcon: Icon(
        Icons.keyboard_arrow_up_rounded,
        color: colors.onSurface.withValues(alpha: 0.7),
      ),
      hintStyle: theme.textTheme.bodyLarge?.copyWith(
        color: colors.onSurface.withValues(alpha: 0.5),
      ),
      headerStyle: theme.textTheme.bodyLarge,
      listItemStyle: theme.textTheme.bodyLarge,
      errorStyle: theme.textTheme.bodySmall?.copyWith(color: colors.error),
      searchFieldDecoration: SearchFieldDecoration(
        fillColor: colors.surfaceContainerHighest,
        prefixIcon: Icon(
          Icons.search_rounded,
          color: colors.onSurface.withValues(alpha: 0.55),
        ),
        hintStyle: theme.textTheme.bodyMedium?.copyWith(
          color: colors.onSurface.withValues(alpha: 0.5),
        ),
        textStyle: theme.textTheme.bodyLarge,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
      ),
    );
  }

  Widget _listItem(
    BuildContext context,
    String text,
    bool isSelected,
    VoidCallback onItemSelect,
  ) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onItemSelect,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(child: Text(text)),
            if (isSelected)
              Icon(
                Icons.check_rounded,
                size: 20,
                color: theme.colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final decoration = _decoration(context);
    final resolvedOverlayHeight = overlayHeight ??
        (_useSearch ? kAppDropdownSearchOverlayHeight : null);
    final wrappedItems = _wrappedItems;
    final resolvedItem = _resolvedWrappedItem;

    Widget headerBuilder(
      BuildContext context,
      _AppDropdownItem<T> item,
      bool enabled,
    ) {
      return Text(
        item.label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: decoration.headerStyle?.copyWith(
          color: enabled
              ? decoration.headerStyle?.color
              : theme.colorScheme.onSurface.withValues(alpha: 0.5),
        ),
      );
    }

    final Widget dropdown;
    if (_useSearch) {
      dropdown = DropdownFlutter<_AppDropdownItem<T>>.search(
        hintText: hint ?? label ?? 'Select',
        searchHintText: searchHint ?? 'common_search'.tr,
        items: wrappedItems,
        initialItem: resolvedItem,
        overlayHeight: resolvedOverlayHeight,
        onChanged: (item) => onChanged?.call(item?.value),
        validator: (item) => validator?.call(item?.value),
        validateOnChange: true,
        enabled: enabled,
        decoration: decoration,
        closedHeaderPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        headerBuilder: headerBuilder,
        listItemBuilder: (context, item, isSelected, onItemSelect) {
          return _listItem(
            context,
            item.label,
            isSelected,
            onItemSelect,
          );
        },
      );
    } else {
      dropdown = DropdownFlutter<_AppDropdownItem<T>>(
        hintText: hint ?? label ?? 'Select',
        items: wrappedItems,
        initialItem: resolvedItem,
        overlayHeight: resolvedOverlayHeight,
        onChanged: (item) => onChanged?.call(item?.value),
        validator: (item) => validator?.call(item?.value),
        validateOnChange: true,
        enabled: enabled,
        decoration: decoration,
        closedHeaderPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        headerBuilder: headerBuilder,
        listItemBuilder: (context, item, isSelected, onItemSelect) {
          return _listItem(
            context,
            item.label,
            isSelected,
            onItemSelect,
          );
        },
      );
    }

    if (label == null) return dropdown;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label!,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 8),
        dropdown,
      ],
    );
  }
}
