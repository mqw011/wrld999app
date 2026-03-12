import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/post.dart';

enum ThreadSortOption { newest, popular }

class PostProvider extends ChangeNotifier {
  static const _storageKey = 'wrld.posts.v1';

  final Map<String, List<Post>> _postsByThread = {
    for (final entry in Post.seededThreadPosts.entries)
      entry.key: List<Post>.from(entry.value),
  };

  ThreadSortOption _threadSort = ThreadSortOption.newest;

  ThreadSortOption get threadSort => _threadSort;

  PostProvider() {
    _loadPersistedPosts();
  }

  List<Post> postsForThread({
    required String genreId,
    required String subGenreId,
  }) {
    final threadKey = Post.buildThreadKey(
      genreId: genreId,
      subGenreId: subGenreId,
    );

    return List<Post>.unmodifiable(_postsByThread[threadKey] ?? const <Post>[]);
  }

  List<Post> sortedPosts({
    required String genreId,
    required String subGenreId,
  }) {
    final sorted = postsForThread(
      genreId: genreId,
      subGenreId: subGenreId,
    ).toList();

    switch (_threadSort) {
      case ThreadSortOption.newest:
        sorted.sort((a, b) {
          final byTimestamp = b.timestamp.compareTo(a.timestamp);
          if (byTimestamp != 0) {
            return byTimestamp;
          }
          return b.likes.compareTo(a.likes);
        });
        break;
      case ThreadSortOption.popular:
        sorted.sort((a, b) {
          final byLikes = b.likes.compareTo(a.likes);
          if (byLikes != 0) {
            return byLikes;
          }
          return b.timestamp.compareTo(a.timestamp);
        });
        break;
    }

    return List<Post>.unmodifiable(sorted);
  }

  void setThreadSort(ThreadSortOption sortOption) {
    if (_threadSort == sortOption) {
      return;
    }

    _threadSort = sortOption;
    notifyListeners();
  }

  Future<void> addPost({
    required String genreId,
    required String subGenreId,
    required String content,
  }) async {
    final trimmedContent = content.trim();
    if (trimmedContent.isEmpty) {
      return;
    }

    final threadKey = Post.buildThreadKey(
      genreId: genreId,
      subGenreId: subGenreId,
    );
    final posts = List<Post>.from(_postsByThread[threadKey] ?? const <Post>[]);

    posts.add(
      Post(
        id: 'user-${DateTime.now().microsecondsSinceEpoch}',
        authorName: 'You',
        authorAvatarUrl: 'https://i.pravatar.cc/150?u=wrld-user',
        content: trimmedContent,
        timestamp: DateTime.now(),
      ),
    );

    _postsByThread[threadKey] = posts;
    notifyListeners();
    await _persistPosts();
  }

  void toggleLike({
    required String genreId,
    required String subGenreId,
    required String postId,
  }) {
    final threadKey = Post.buildThreadKey(
      genreId: genreId,
      subGenreId: subGenreId,
    );
    final posts = List<Post>.from(_postsByThread[threadKey] ?? const <Post>[]);
    final postIndex = posts.indexWhere((post) => post.id == postId);

    if (postIndex == -1) {
      return;
    }

    final currentPost = posts[postIndex];
    final nextLikedState = !currentPost.isLikedByUser;
    final nextLikes = nextLikedState
        ? currentPost.likes + 1
        : (currentPost.likes > 0 ? currentPost.likes - 1 : 0);

    posts[postIndex] = currentPost.copyWith(
      isLikedByUser: nextLikedState,
      likes: nextLikes,
    );

    _postsByThread[threadKey] = posts;
    notifyListeners();
    _persistPosts();
  }

  Future<void> _loadPersistedPosts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawJson = prefs.getString(_storageKey);
      if (rawJson == null || rawJson.isEmpty) {
        return;
      }

      final decoded = jsonDecode(rawJson);
      if (decoded is! Map<String, dynamic>) {
        return;
      }

      for (final entry in decoded.entries) {
        final rawPosts = entry.value;
        if (rawPosts is! List) {
          continue;
        }

        _postsByThread[entry.key] = rawPosts
            .whereType<Map>()
            .map(
              (item) => Post.fromJson(
                Map<String, dynamic>.from(item.cast<String, dynamic>()),
              ),
            )
            .toList();
      }

      notifyListeners();
    } catch (_) {
      // Ignore malformed persisted data and keep seeded in-memory posts.
    }
  }

  Future<void> _persistPosts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final payload = <String, List<Map<String, dynamic>>>{
        for (final entry in _postsByThread.entries)
          entry.key: entry.value.map((post) => post.toJson()).toList(),
      };
      await prefs.setString(_storageKey, jsonEncode(payload));
    } catch (_) {
      // Ignore persistence failures for this in-memory experience.
    }
  }
}
