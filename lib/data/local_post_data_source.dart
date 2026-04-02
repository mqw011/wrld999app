import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/post.dart';

abstract class PostDataSource {
  Future<Map<String, List<Post>>> loadThreads();

  Future<void> saveThreads(Map<String, List<Post>> threads);
}

class LocalPostDataSource implements PostDataSource {
  static const String _storageKey = 'wrld.posts.persistence.v1';

  @override
  Future<Map<String, List<Post>>> loadThreads() async {
    final prefs = await SharedPreferences.getInstance();
    final rawJson = prefs.getString(_storageKey);

    if (rawJson == null || rawJson.isEmpty) {
      return _seededThreads();
    }

    try {
      final decoded = jsonDecode(rawJson);
      if (decoded is! Map<String, dynamic>) {
        return _seededThreads();
      }

      final persistedThreads = <String, List<Post>>{};
      for (final entry in decoded.entries) {
        final value = entry.value;
        if (value is! List) {
          continue;
        }

        persistedThreads[entry.key] = value
            .whereType<Map>()
            .map(
              (postJson) => Post.fromJson(Map<String, dynamic>.from(postJson)),
            )
            .toList(growable: false);
      }

      if (persistedThreads.isEmpty) {
        return _seededThreads();
      }

      final seededThreads = _seededThreads();
      for (final entry in seededThreads.entries) {
        persistedThreads.putIfAbsent(entry.key, () => entry.value);
      }

      return persistedThreads;
    } catch (_) {
      return _seededThreads();
    }
  }

  @override
  Future<void> saveThreads(Map<String, List<Post>> threads) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = <String, dynamic>{
      for (final entry in threads.entries)
        entry.key: entry.value
            .map((post) => post.toJson())
            .toList(growable: false),
    };

    await prefs.setString(_storageKey, jsonEncode(payload));
  }

  Map<String, List<Post>> _seededThreads() {
    return {
      for (final entry in Post.seededThreadPosts.entries)
        entry.key: entry.value.map((post) => post.copyWith()).toList(),
    };
  }
}
