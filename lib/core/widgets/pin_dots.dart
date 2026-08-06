import 'package:flutter/material.dart';

/// Visual indicator for entered PIN digits.
class PinDots extends StatelessWidget {
  const PinDots({
    super.key,
    required this.length,
    required this.maxLength,
    this.hasError = false,
  });

  final int length;
  final int maxLength;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = hasError
        ? theme.colorScheme.error
        : theme.colorScheme.primary;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < maxLength; i++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i < length ? color : Colors.transparent,
                border: Border.all(color: color, width: 2),
              ),
            ),
          ),
      ],
    );
  }
}
