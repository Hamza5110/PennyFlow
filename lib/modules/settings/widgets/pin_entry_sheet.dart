import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/validation_constants.dart';
import '../../../core/widgets/app_bottom_sheet.dart';
import '../../../core/widgets/pin_dots.dart';
import '../../../core/widgets/pin_pad.dart';

/// Single-step PIN entry sheet for verification flows.
class PinEntrySheet extends StatefulWidget {
  const PinEntrySheet({
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
      PinEntrySheet(title: title, subtitle: subtitle),
      isScrollControlled: true,
      backgroundColor: AppBottomSheet.backgroundColorFromTheme,
      shape: AppBottomSheet.shape,
    );
  }

  @override
  State<PinEntrySheet> createState() => _PinEntrySheetState();
}

class _PinEntrySheetState extends State<PinEntrySheet> {
  final ValueNotifier<String> _buffer = ValueNotifier('');

  @override
  void dispose() {
    _buffer.dispose();
    super.dispose();
  }

  void _onDigit(String digit) {
    final current = _buffer.value;
    if (current.length >= ValidationConstants.maxPinLength) return;

    final next = current + digit;
    _buffer.value = next;

    if (next.length == ValidationConstants.minPinLength ||
        next.length == ValidationConstants.maxPinLength) {
      Get.back<String?>(result: next);
    }
  }

  void _onBackspace() {
    final current = _buffer.value;
    if (current.isEmpty) return;
    _buffer.value = current.substring(0, current.length - 1);
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
            Text(
              widget.title ?? 'security_enter_current_pin'.tr,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              widget.subtitle ?? 'security_pin_hint'.tr,
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
                maxLength: ValidationConstants.minPinLength,
              ),
            ),
            const SizedBox(height: 24),
            PinPad(
              key: const ValueKey('pin_entry_pad'),
              onDigit: _onDigit,
              onBackspace: _onBackspace,
            ),
          ],
        ),
      ),
    );
  }
}
