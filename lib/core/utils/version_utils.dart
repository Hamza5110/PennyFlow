/// Semantic version helpers for in-app update checks (FR-169).
abstract final class VersionUtils {
  static List<int> parse(String raw) {
    final cleaned = raw.trim().replaceFirst(RegExp(r'^[vV]'), '');
    final core = cleaned.split('+').first.split('-').first;
    final parts = core.split('.').map((part) {
      final digits = RegExp(r'^\d+').stringMatch(part);
      return int.tryParse(digits ?? '0') ?? 0;
    }).toList();

    while (parts.length < 3) {
      parts.add(0);
    }
    return parts.take(3).toList();
  }

  static int compare(String left, String right) {
    final a = parse(left);
    final b = parse(right);
    for (var i = 0; i < 3; i++) {
      if (a[i] != b[i]) return a[i].compareTo(b[i]);
    }
    return 0;
  }

  static bool isNewer(String candidate, String current) =>
      compare(candidate, current) > 0;
}
