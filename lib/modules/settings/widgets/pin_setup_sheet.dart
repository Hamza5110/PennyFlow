import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/validation_constants.dart';
import '../../../core/widgets/app_bottom_sheet.dart';
import '../../../core/widgets/pin_dots.dart';
import '../../../core/widgets/pin_pad.dart';

enum PinSetupStep { enter, confirm }

/// Bottom sheet for creating or confirming a PIN.
class PinSetupSheet extends StatefulWidget {
  const PinSetupSheet({
    super.key,
    this.title,
    this.subtitle,
  });

  final String? title;
  final String? subtitle;

  static Future<String?> show({
    String? title,
    String? subtitle,
  }) {
    return Get.bottomSheet<String?>(
      PinSetupSheet(
        title: title,
        subtitle: subtitle,
      ),
      isScrollControlled: true,
      backgroundColor: AppBottomSheet.backgroundColorFromTheme,
      shape: AppBottomSheet.shape,
    );
  }

  @override
  State<PinSetupSheet> createState() => _PinSetupSheetState();
}

class _PinSetupSheetState extends State<PinSetupSheet> {
  final ValueNotifier<String> _buffer = ValueNotifier('');

  PinSetupStep _step = PinSetupStep.enter;
  String? _firstPin;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void dispose() {
    _buffer.dispose();
    super.dispose();
  }

  int _displayLengthFor(String buffer) =>
      buffer.length >= ValidationConstants.minPinLength &&
              buffer.length < ValidationConstants.maxPinLength
          ? ValidationConstants.maxPinLength
          : ValidationConstants.minPinLength;

  void _onDigit(String digit) {
    final current = _buffer.value;
    if (current.length >= ValidationConstants.maxPinLength) return;

    final next = current + digit;
    _buffer.value = next;

    if (_hasError || _errorMessage != null) {
      setState(() {
        _hasError = false;
        _errorMessage = null;
      });
    }

    if (next.length == ValidationConstants.minPinLength ||
        next.length == ValidationConstants.maxPinLength) {
      _maybeAdvance(next);
    }
  }

  void _onBackspace() {
    final current = _buffer.value;
    if (current.isEmpty) return;
    _buffer.value = current.substring(0, current.length - 1);

    if (_hasError || _errorMessage != null) {
      setState(() {
        _hasError = false;
        _errorMessage = null;
      });
    }
  }

  void _maybeAdvance(String pin) {
    if (pin.length != ValidationConstants.minPinLength &&
        pin.length != ValidationConstants.maxPinLength) {
      return;
    }

    if (_step == PinSetupStep.enter) {
      setState(() {
        _step = PinSetupStep.confirm;
        _firstPin = pin;
      });
      _buffer.value = '';
      return;
    }

    if (pin != _firstPin) {
      setState(() {
        _hasError = true;
        _errorMessage = 'security_pin_mismatch'.tr;
        _step = PinSetupStep.enter;
        _firstPin = null;
      });
      _buffer.value = '';
      return;
    }

    Get.back<String?>(result: pin);
  }

  String get _title {
    if (widget.title != null) return widget.title!;
    return _step == PinSetupStep.enter
        ? 'security_create_pin'.tr
        : 'security_confirm_pin'.tr;
  }

  String get _subtitle {
    if (widget.subtitle != null) return widget.subtitle!;
    return 'security_pin_hint'.tr;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(_title, style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              _subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ValueListenableBuilder<String>(
              valueListenable: _buffer,
              builder: (context, buffer, _) => PinDots(
                length: buffer.length,
                maxLength: _displayLengthFor(buffer),
                hasError: _hasError,
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 24),
            PinPad(
              key: const ValueKey('pin_setup_pad'),
              onDigit: _onDigit,
              onBackspace: _onBackspace,
            ),
          ],
        ),
      ),
    );
  }
}
