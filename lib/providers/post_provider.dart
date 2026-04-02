import 'package:flutter/material.dart';

import '../data/local_post_data_source.dart';
import '../models/post.dart';

class PostProvider extends ChangeNotifier {
  PostProvider({PostDataSource? dataSource})
    : _dataSource = dataSource ?? LocalPostDataSource() {
    _initialLoad = _loadThreads();
  }

  final PostDataSource _dataSource;
  late final Future<void> _initialLoad;
  Map<String, List<Post>> _threads = {
    for (final entry in Post.seededThreadPosts.entries)
      entry.key: entry.value.map((post) => post.copyWith()).toList(),
  };
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;

  Future<void> waitUntilLoaded() => _initialLoad;

  List<Post> postsForThread({
    required String genreId,
    required String subGenreId,
  }) {
    final threadKey = Post.buildThreadKey(
      genreId: genreId,
      subGenreId: subGenreId,
    );

    return List<Post>.unmodifiable(_threads[threadKey] ?? const <Post>[]);
  }

  Future<void> addPost({
    required String genreId,
    required String subGenreId,
    required String content,
  }) async {
    await waitUntilLoaded();

    final trimmedContent = content.trim();
    if (trimmedContent.isEmpty) {
      return;
    }

    final threadKey = Post.buildThreadKey(
      genreId: genreId,
      subGenreId: subGenreId,
    );
    final updatedPosts = [
      ...?_threads[threadKey],
      Post(
        id: 'user-${DateTime.now().microsecondsSinceEpoch}',
        authorName: 'You',
        authorAvatarUrl: 'https://i.pravatar.cc/150?img=12',
        content: trimmedContent,
        timestamp: DateTime.now(),
      ),
    ];

    _threads = {..._threads, threadKey: updatedPosts};
    notifyListeners();
    await _persistThreads();
  }

  Future<void> toggleLike({
    required String genreId,
    required String subGenreId,
    required String postId,
  }) async {
    await waitUntilLoaded();

    final threadKey = Post.buildThreadKey(
      genreId: genreId,
      subGenreId: subGenreId,
    );
    final posts = _threads[threadKey];
    if (posts == null) {
      return;
    }

    var didChange = false;
    final updatedPosts = posts
        .map((post) {
          if (post.id != postId) {
            return post;
          }

          didChange = true;
          final nextLikedState = !post.isLikedByUser;
          return post.copyWith(
            likes: nextLikedState
                ? post.likes + 1
                : (post.likes > 0 ? post.likes - 1 : 0),
            isLikedByUser: nextLikedState,
          );
        })
        .toList(growable: false);

    if (!didChange) {
      return;
    }

    _threads = {..._threads, threadKey: updatedPosts};
    notifyListeners();
    await _persistThreads();
  }

  Future<void> reload() async {
    await _loadThreads();
  }

  Future<void> _loadThreads() async {
    final loadedThreads = await _dataSource.loadThreads();
    _threads = _cloneThreads(loadedThreads);
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> _persistThreads() async {
    await _dataSource.saveThreads(_threads);
  }

  Map<String, List<Post>> _cloneThreads(Map<String, List<Post>> source) {
    return {
      for (final entry in source.entries)
        entry.key: entry.value.map((post) => post.copyWith()).toList(),
    };
  }
}
