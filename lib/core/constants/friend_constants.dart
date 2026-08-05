/// Friend money transaction types (FR-045).
abstract final class FriendTransactionTypes {
  static const String given = 'given';
  static const String received = 'received';
}

/// Derived friend transaction statuses (FR-047).
abstract final class FriendTransactionStatus {
  static const String pending = 'pending';
  static const String partiallyPaid = 'partially_paid';
  static const String completed = 'completed';
}
