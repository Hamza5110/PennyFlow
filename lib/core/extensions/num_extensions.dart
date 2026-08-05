import 'package:intl/intl.dart';

/// Numeric formatting helpers. Currency symbol is presentation-only (FR-186).
extension NumExtensions on num {
  String asFixed([int fractionDigits = 2]) => toStringAsFixed(fractionDigits);

  /// Formats with grouping separators; pass [symbol] from settings/currency.
  String asCurrency({
    String symbol = 'Rs.',
    int decimalDigits = 2,
    String locale = 'en_PK',
  }) {
    final formatter = NumberFormat.currency(
      locale: locale,
      symbol: symbol.isEmpty ? '' : '$symbol ',
      decimalDigits: decimalDigits,
    );
    return formatter.format(this);
  }

  String asCompact({String locale = 'en'}) =>
      NumberFormat.compact(locale: locale).format(this);

  bool get isPositive => this > 0;

  bool get isNegative => this < 0;

  double get asDouble => toDouble();
}

extension DoubleMoneyExtensions on double {
  /// Rounds to 2 decimal places using banker's-unaware half-up via string path.
  double get moneyRounded =>
      double.parse(toStringAsFixed(2));
}
