/// Reminder type keys (FR-133).
abstract final class ReminderTypes {
  static const String billDue = 'bill_due';
  static const String friendPaymentDue = 'friend_payment_due';
  static const String subscriptionRenewal = 'subscription_renewal';
  static const String insurance = 'insurance';
  static const String custom = 'custom';

  static const List<String> all = [
    billDue,
    friendPaymentDue,
    subscriptionRenewal,
    insurance,
    custom,
  ];

  static const List<String> manualTypes = [
    billDue,
    subscriptionRenewal,
    insurance,
    custom,
  ];
}
