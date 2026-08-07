import 'package:flutter/material.dart';

/// A single selectable option for [SettingsPickerView].
class SettingsPickerOption<T> {
  const SettingsPickerOption({
    required this.value,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
  });

  final T value;
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
}

/// Full-screen settings picker with card-style selectable options.
class SettingsPickerView<T> extends StatelessWidget {
  const SettingsPickerView({
    super.key,
    required this.title,
    required this.options,
    required this.selectedValue,
    required this.onSelected,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final List<SettingsPickerOption<T>> options;
  final T selectedValue;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          if (subtitle != null) ...[
            Text(
              subtitle!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.65),
              ),
            ),
            const SizedBox(height: 16),
          ],
          ...options.map((option) {
            final isSelected = option.value == selectedValue;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _OptionCard(
                title: option.title,
                subtitle: option.subtitle,
                leading: option.leading,
                trailing: option.trailing,
                isSelected: isSelected,
                onTap: () => onSelected(option.value),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.title,
    required this.isSelected,
    required this.onTap,
    this.subtitle,
    this.leading,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: isSelected
          ? colorScheme.primaryContainer.withValues(alpha: 0.35)
          : colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected
              ? colorScheme.primary
              : colorScheme.outline.withValues(alpha: 0.35),
          width: isSelected ? 2 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: 14),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w600,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 8),
                trailing!,
              ],
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: isSelected
                    ? Icon(
                        Icons.check_circle_rounded,
                        key: const ValueKey('selected'),
                        color: colorScheme.primary,
                        size: 24,
                      )
                    : Icon(
                        Icons.circle_outlined,
                        key: const ValueKey('unselected'),
                        color: colorScheme.outline,
                        size: 24,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
