import 'package:flutter/material.dart';

/// Numeric keypad for PIN entry.
class PinPad extends StatelessWidget {
  const PinPad({
    super.key,
    required this.onDigit,
    required this.onBackspace,
    this.onBiometric,
    this.showBiometric = false,
  });

  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;
  final VoidCallback? onBiometric;
  final bool showBiometric;

  static const _keySpacing = 12.0;
  static const _keyPadding = 6.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _row(const ['1', '2', '3']),
        const SizedBox(height: _keySpacing),
        _row(const ['4', '5', '6']),
        const SizedBox(height: _keySpacing),
        _row(const ['7', '8', '9']),
        const SizedBox(height: _keySpacing),
        Row(
          children: [
            Expanded(
              child: showBiometric
                  ? _PinKey(
                      icon: Icons.fingerprint_rounded,
                      onPressed: onBiometric,
                    )
                  : const SizedBox(),
            ),
            Expanded(
              child: _PinKey(
                label: '0',
                onPressed: () => onDigit('0'),
              ),
            ),
            Expanded(
              child: _PinKey(
                icon: Icons.backspace_outlined,
                onPressed: onBackspace,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _row(List<String> digits) {
    return Row(
      children: [
        for (final digit in digits)
          Expanded(
            child: _PinKey(
              label: digit,
              onPressed: () => onDigit(digit),
            ),
          ),
      ],
    );
  }
}

class _PinKey extends StatefulWidget {
  const _PinKey({
    this.label,
    this.icon,
    this.onPressed,
  });

  final String? label;
  final IconData? icon;
  final VoidCallback? onPressed;

  @override
  State<_PinKey> createState() => _PinKeyState();
}

class _PinKeyState extends State<_PinKey> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value || !mounted) return;
    setState(() => _pressed = value);
  }

  void _handleDown(PointerDownEvent event) {
    if (widget.onPressed == null) return;
    widget.onPressed!();
    _setPressed(true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor = theme.colorScheme.surfaceContainerHighest;
    final pressedColor = Color.alphaBlend(
      theme.colorScheme.onSurface.withValues(alpha: 0.08),
      baseColor,
    );

    return Padding(
      padding: const EdgeInsets.all(PinPad._keyPadding),
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: _handleDown,
        onPointerUp: (_) => _setPressed(false),
        onPointerCancel: (_) => _setPressed(false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 60),
          curve: Curves.easeOut,
          height: 64,
          decoration: BoxDecoration(
            color: _pressed ? pressedColor : baseColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: widget.icon != null
                ? Icon(widget.icon, size: 28)
                : Text(
                    widget.label ?? '',
                    style: theme.textTheme.headlineSmall,
                  ),
          ),
        ),
      ),
    );
  }
}
