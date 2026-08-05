import 'package:equatable/equatable.dart';

/// Form / service input for creating or updating a payment account.
class PaymentAccountInput extends Equatable {
  const PaymentAccountInput({
    required this.name,
    required this.type,
    this.openingBalance = 0,
  });

  final String name;
  final String type;
  final double openingBalance;

  @override
  List<Object?> get props => [name, type, openingBalance];
}
