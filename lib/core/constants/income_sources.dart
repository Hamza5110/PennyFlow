/// Predefined income sources (FR-036).
abstract final class IncomeSources {
  static const String salary = 'salary';
  static const String freelance = 'freelance';
  static const String bonus = 'bonus';
  static const String gift = 'gift';
  static const String refund = 'refund';
  static const String business = 'business';
  static const String custom = 'custom';

  static const List<String> predefinedKeys = [
    salary,
    freelance,
    bonus,
    gift,
    refund,
    business,
  ];

  static const Map<String, String> labelKeys = {
    salary: 'income_source_salary',
    freelance: 'income_source_freelance',
    bonus: 'income_source_bonus',
    gift: 'income_source_gift',
    refund: 'income_source_refund',
    business: 'income_source_business',
    custom: 'income_source_custom',
  };

  static bool isPredefinedKey(String source) => predefinedKeys.contains(source);

  static String colorHexFor(String source) {
    switch (source) {
      case salary:
        return '#059669';
      case freelance:
        return '#0EA5E9';
      case bonus:
        return '#8B5CF6';
      case gift:
        return '#EC4899';
      case refund:
        return '#F59E0B';
      case business:
        return '#14B8A6';
      default:
        return '#64748B';
    }
  }
}
