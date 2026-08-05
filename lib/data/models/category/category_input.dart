import 'package:equatable/equatable.dart';

/// Form / service input for creating or updating a category.
class CategoryInput extends Equatable {
  const CategoryInput({
    required this.name,
    required this.colorHex,
    required this.iconKey,
  });

  final String name;
  final String colorHex;
  final String iconKey;

  @override
  List<Object?> get props => [name, colorHex, iconKey];
}
