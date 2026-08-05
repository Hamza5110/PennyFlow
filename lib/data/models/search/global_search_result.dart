import 'package:equatable/equatable.dart';

enum GlobalSearchResultType {
  expense,
  income,
  friendTransaction,
}

class GlobalSearchResult extends Equatable {
  const GlobalSearchResult({
    required this.type,
    required this.recordId,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.date,
    this.colorHex,
  });

  final GlobalSearchResultType type;
  final int recordId;
  final String title;
  final String subtitle;
  final double amount;
  final DateTime date;
  final String? colorHex;

  @override
  List<Object?> get props =>
      [type, recordId, title, subtitle, amount, date, colorHex];
}
