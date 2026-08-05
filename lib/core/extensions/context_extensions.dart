import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// BuildContext helpers for theme, media, and navigation.
extension ContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);

  ColorScheme get colors => theme.colorScheme;

  TextTheme get textTheme => theme.textTheme;

  MediaQueryData get mediaQuery => MediaQuery.of(this);

  Size get screenSize => mediaQuery.size;

  double get screenWidth => screenSize.width;

  double get screenHeight => screenSize.height;

  bool get isDarkMode => theme.brightness == Brightness.dark;

  EdgeInsets get padding => mediaQuery.padding;

  bool get isKeyboardVisible => mediaQuery.viewInsets.bottom > 0;

  void hideKeyboard() => FocusScope.of(this).unfocus();

  /// True for widths under the Material compact breakpoint.
  bool get isCompact => screenWidth < 600;
}

/// GetX-friendly snackbar/dialog helpers without needing BuildContext.
extension GetxUiExtensions on GetInterface {
  void dismissKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }
}
