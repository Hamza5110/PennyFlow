import '../constants/validation_constants.dart';
import '../extensions/string_extensions.dart';

/// Pure validation helpers shared by forms and services.
///
/// Return `null` when valid; otherwise return a user-facing error string.
/// Localization keys can replace hard-coded strings later.
abstract final class AppValidators {
  static String? required(String? value, {String field = 'This field'}) {
    if (value == null || value.isBlank) return '$field is required';
    return null;
  }

  static String? amount(String? value) {
    final requiredError = required(value, field: 'Amount');
    if (requiredError != null) return requiredError;

    final parsed = double.tryParse(value!.trim());
    if (parsed == null) return 'Enter a valid amount';
    if (parsed < ValidationConstants.minAmount) {
      return 'Amount must be greater than 0';
    }
    if (parsed > ValidationConstants.maxAmount) {
      return 'Amount is too large';
    }

    final parts = value.trim().split('.');
    if (parts.length == 2 &&
        parts[1].length > ValidationConstants.amountDecimalPlaces) {
      return 'Use at most ${ValidationConstants.amountDecimalPlaces} decimal places';
    }
    return null;
  }

  static String? amountValue(double? value) {
    if (value == null) return 'Amount is required';
    if (value < ValidationConstants.minAmount) {
      return 'Amount must be greater than 0';
    }
    if (value > ValidationConstants.maxAmount) {
      return 'Amount is too large';
    }
    return null;
  }

  static String? name(
    String? value, {
    String field = 'Name',
    int maxLength = ValidationConstants.maxCategoryNameLength,
  }) {
    final requiredError = required(value, field: field);
    if (requiredError != null) return requiredError;
    final trimmed = value!.trim();
    if (trimmed.length > maxLength) {
      return '$field must be at most $maxLength characters';
    }
    return null;
  }

  static String? notes(String? value) {
    if (value == null || value.isEmpty) return null;
    if (value.length > ValidationConstants.maxNotesLength) {
      return 'Notes must be at most ${ValidationConstants.maxNotesLength} characters';
    }
    return null;
  }

  static String? pin(String? value) {
    final requiredError = required(value, field: 'PIN');
    if (requiredError != null) return requiredError;
    final digits = value!.digitsOnly;
    if (digits != value) return 'PIN must be numeric';
    if (digits.length != ValidationConstants.minPinLength &&
        digits.length != ValidationConstants.maxPinLength) {
      return 'PIN must be ${ValidationConstants.minPinLength} or ${ValidationConstants.maxPinLength} digits';
    }
    return null;
  }
}
