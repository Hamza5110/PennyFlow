import 'formatters.dart';

/// Shared text matching for list search and global search (FR-100).
abstract final class SearchMatchUtils {
  static bool matches(
    String query,
    List<String> fields, {
    DateTime? date,
  }) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return true;

    final tokens = <String>[
      for (final field in fields)
        if (field.trim().isNotEmpty) field.trim(),
      if (date != null) ..._dateTokens(date),
    ];

    final haystack = tokens.join(' ').toLowerCase();
    return haystack.contains(normalized);
  }

  static List<String> _dateTokens(DateTime date) {
    return [
      date.day.toString(),
      date.month.toString(),
      date.year.toString(),
      AppFormatters.date(date),
      AppFormatters.dateTime(date),
      '${date.day}/${date.month}/${date.year}',
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}',
    ];
  }
}
