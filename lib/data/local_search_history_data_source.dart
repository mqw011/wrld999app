// Place this file in: lib/data/local_search_history_data_source.dart

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

abstract class SearchHistoryDataSource {
  Future<List<String>> loadSearchHistory();

  Future<void> saveSearchHistory(List<String> searchHistory);
}

class LocalSearchHistoryDataSource implements SearchHistoryDataSource {
  static const String _storageKey = 'wrld.search.history.v1';

  @override
  Future<List<String>> loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final rawJson = prefs.getString(_storageKey);

    if (rawJson == null || rawJson.isEmpty) {
      return const <String>[];
    }

    try {
      final decoded = jsonDecode(rawJson);
      if (decoded is! List) {
        return const <String>[];
      }

      return decoded
          .whereType<String>()
          .map((query) => query.trim())
          .where((query) => query.isNotEmpty)
          .toList(growable: false);
    } catch (_) {
      return const <String>[];
    }
  }

  @override
  Future<void> saveSearchHistory(List<String> searchHistory) async {
    final prefs = await SharedPreferences.getInstance();
    final sanitizedHistory = searchHistory
        .map((query) => query.trim())
        .where((query) => query.isNotEmpty)
        .toList(growable: false);

    await prefs.setString(_storageKey, jsonEncode(sanitizedHistory));
  }
}
