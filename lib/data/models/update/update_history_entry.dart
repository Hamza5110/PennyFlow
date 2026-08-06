import 'package:equatable/equatable.dart';

/// Local update history log entry (FR-174).
class UpdateHistoryEntry extends Equatable {
  const UpdateHistoryEntry({
    required this.version,
    required this.installedAt,
    required this.status,
    this.notes,
  });

  factory UpdateHistoryEntry.fromJson(Map<String, dynamic> json) {
    return UpdateHistoryEntry(
      version: json['version'] as String,
      installedAt: DateTime.parse(json['installedAt'] as String),
      status: json['status'] as String? ?? 'installed',
      notes: json['notes'] as String?,
    );
  }

  final String version;
  final DateTime installedAt;
  final String status;
  final String? notes;

  Map<String, dynamic> toJson() => {
        'version': version,
        'installedAt': installedAt.toIso8601String(),
        'status': status,
        if (notes != null) 'notes': notes,
      };

  @override
  List<Object?> get props => [version, installedAt, status, notes];
}
