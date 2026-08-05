import 'package:equatable/equatable.dart';

class CategoryStatistic extends Equatable {
  const CategoryStatistic({
    required this.categoryId,
    required this.name,
    required this.colorHex,
    required this.amount,
    required this.percentage,
  });

  final int categoryId;
  final String name;
  final String colorHex;
  final double amount;
  final double percentage;

  @override
  List<Object?> get props => [categoryId, name, colorHex, amount, percentage];
}
