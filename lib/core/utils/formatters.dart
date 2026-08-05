import 'package:intl/intl.dart';

import '../extensions/date_extensions.dart';

/// Presentation formatters. Prefer extensions for one-liners; use this for
/// multi-argument or currency-aware formatting driven by settings.
abstract final class AppFormatters {
  static String currency(
    num amount, {
    required String currencyCode,
    String? symbol,
    int decimalDigits = 2,
  }) {
    final resolvedSymbol = symbol ?? _defaultSymbol(currencyCode);
    return NumberFormat.currency(
      name: currencyCode,
      symbol: '$resolvedSymbol ',
      decimalDigits: decimalDigits,
    ).format(amount);
  }

  static String date(DateTime value, {String pattern = 'dd MMM yyyy'}) =>
      value.format(pattern);

  static String dateTime(DateTime value) =>
      value.format('dd MMM yyyy · hh:mm a');

  static String fileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  static String percent(double ratio, {int decimals = 0}) =>
      '${(ratio * 100).toStringAsFixed(decimals)}%';

  static String _defaultSymbol(String code) {
    switch (code.toUpperCase()) {
      case 'PKR':
        return 'Rs.';
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'INR':
        return '₹';
      default:
        return code;
    }
  }
}
