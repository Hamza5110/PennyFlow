/// Recurring transaction type keys (SRS §20.10).
abstract final class RecurringTransactionTypes {
  static const String expense = 'expense';
  static const String income = 'income';

  static const List<String> all = [expense, income];
}

/// Recurring frequency keys (FR-125).
abstract final class RecurringFrequencies {
  static const String daily = 'daily';
  static const String weekly = 'weekly';
  static const String monthly = 'monthly';
  static const String yearly = 'yearly';

  static const List<String> all = [daily, weekly, monthly, yearly];
}
