class FriendFormArgs {
  const FriendFormArgs({this.friendId});
  final int? friendId;
}

class FriendDetailArgs {
  const FriendDetailArgs({required this.friendId});
  final int friendId;
}

class FriendTransactionFormArgs {
  const FriendTransactionFormArgs({
    this.transactionId,
    this.friendId,
    this.type,
  });

  final int? transactionId;
  final int? friendId;
  final String? type;
}

class FriendTransactionDetailArgs {
  const FriendTransactionDetailArgs({required this.transactionId});
  final int transactionId;
}

class RepaymentFormArgs {
  const RepaymentFormArgs({required this.transactionId});
  final int transactionId;
}
