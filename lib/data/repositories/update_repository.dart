import 'dart:convert';

import '../../core/constants/storage_keys.dart';
import '../models/update/update_history_entry.dart';
import '../../services/storage/local_storage_service.dart';

/// Persists update history in SharedPreferences (FR-174).
class UpdateRepository {
  UpdateRepository(this._storage);

  final LocalStorageService _storage;

  Future<List<UpdateHistoryEntry>> getHistory() async {
    final raw = _storage.getString(StorageKeys.updateHistory);
    if (raw == null || raw.isEmpty) return [];

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) => UpdateHistoryEntry.fromJson(item as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.installedAt.compareTo(a.installedAt));
  }

  Future<void> addHistory(UpdateHistoryEntry entry) async {
    final history = await getHistory();
    history.removeWhere((item) => item.version == entry.version);
    history.insert(0, entry);
    final trimmed = history.take(20).toList();
    await _storage.setString(
      StorageKeys.updateHistory,
      jsonEncode(trimmed.map((item) => item.toJson()).toList()),
    );
  }
}
