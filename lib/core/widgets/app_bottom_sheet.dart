import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Shared presentation defaults for app bottom sheets.
abstract final class AppBottomSheet {
  static const ShapeBorder shape = RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  );

  static Color backgroundColor(BuildContext context) =>
      Theme.of(context).colorScheme.surface;

  static Color get backgroundColorFromTheme =>
      Get.theme.colorScheme.surface;
}
