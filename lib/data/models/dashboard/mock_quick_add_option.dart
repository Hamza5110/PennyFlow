import 'package:equatable/equatable.dart';

/// Category/account pickers for mock Quick Add (Phase 3 demo only).
class MockQuickAddCategory extends Equatable {
  const MockQuickAddCategory({
    required this.id,
    required this.name,
    required this.colorHex,
  });

  final String id;
  final String name;
  final String colorHex;

  @override
  List<Object?> get props => [id, name, colorHex];
}

class MockQuickAddAccount extends Equatable {
  const MockQuickAddAccount({
    required this.id,
    required this.name,
  });

  final String id;
  final String name;

  @override
  List<Object?> get props => [id, name];
}
