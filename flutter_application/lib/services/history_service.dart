import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/history_entry.dart';

/// Stores and retrieves the user's scan history locally on-device.
///
/// Kindwise's API doesn't offer a "list all my past identifications"
/// endpoint — only single-result retrieval by access_token — so history
/// is built and owned locally, one entry per successful scan.
class HistoryService {
  static const String _storageKey = 'scan_history';
  static const int _maxEntries = 200;

  /// Call this right after a successful PlantIdService.identify() call,
  /// passing the resulting access_token and a couple of display fields.
  static Future<void> addEntry(HistoryEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final entries = await getHistory();

    entries.insert(0, entry);
    if (entries.length > _maxEntries) {
      entries.removeRange(_maxEntries, entries.length);
    }

    final encoded = jsonEncode(entries.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }

  /// Returns all saved entries, most recent first.
  static Future<List<HistoryEntry>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return [];

    try {
      final List<dynamic> decoded = jsonDecode(raw);
      return decoded
          .map((e) => HistoryEntry.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> deleteEntry(String accessToken) async {
    final prefs = await SharedPreferences.getInstance();
    final entries = await getHistory();
    entries.removeWhere((e) => e.accessToken == accessToken);

    // Best-effort cleanup of the cached thumbnail file on disk.
    final removed = entries.where((e) => e.accessToken == accessToken);
    for (final e in removed) {
      final file = File(e.imagePath);
      if (await file.exists()) {
        await file.delete();
      }
    }

    final encoded = jsonEncode(entries.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}