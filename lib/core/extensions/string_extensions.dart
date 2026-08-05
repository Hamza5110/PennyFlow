extension StringExtensions on String {
  bool get isBlank => trim().isEmpty;

  bool get isNotBlank => !isBlank;

  String get capitalized {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  String get titleCase => split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty)
      .map((w) => w.capitalized)
      .join(' ');

  /// Null-safe trim for form fields.
  String get trimmed => trim();

  bool equalsIgnoreCase(String other) =>
      toLowerCase() == other.toLowerCase();

  /// Digits-only PIN / amount helper.
  String get digitsOnly => replaceAll(RegExp(r'[^0-9]'), '');

  /// Truncates with ellipsis when longer than [max].
  String ellipsize(int max) {
    if (length <= max) return this;
    if (max <= 1) return '…';
    return '${substring(0, max - 1)}…';
  }
}

extension NullableStringExtensions on String? {
  bool get isNullOrBlank => this == null || this!.isBlank;

  String orDefault([String fallback = '']) =>
      isNullOrBlank ? fallback : this!;
}
