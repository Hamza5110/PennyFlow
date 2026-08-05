import 'package:flutter/material.dart';

enum AppButtonVariant { filled, outlined, text, tonal }

/// Reusable Material 3 button with loading state.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.filled,
    this.isLoading = false,
    this.icon,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final IconData? icon;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : _labelRow();

    final effectiveOnPressed = isLoading ? null : onPressed;

    final button = switch (variant) {
      AppButtonVariant.filled => FilledButton(
          onPressed: effectiveOnPressed,
          child: child,
        ),
      AppButtonVariant.outlined => OutlinedButton(
          onPressed: effectiveOnPressed,
          child: child,
        ),
      AppButtonVariant.text => TextButton(
          onPressed: effectiveOnPressed,
          child: child,
        ),
      AppButtonVariant.tonal => FilledButton.tonal(
          onPressed: effectiveOnPressed,
          child: child,
        ),
    };

    if (!expand) return button;
    return SizedBox(width: double.infinity, child: button);
  }

  Widget _labelRow() {
    if (icon == null) return Text(label);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }
}
