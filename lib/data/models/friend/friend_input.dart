import 'package:equatable/equatable.dart';

class FriendInput extends Equatable {
  const FriendInput({required this.name, this.phone});

  final String name;
  final String? phone;

  @override
  List<Object?> get props => [name, phone];
}
