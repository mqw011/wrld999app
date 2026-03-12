class Post {
  final String id;
  final String authorName;
  final String authorAvatarUrl;
  final String content;
  final DateTime timestamp;
  final int likes;
  final int replies;
  final String? mediaUrl;
  final PostMediaType? mediaType;

  const Post({
    required this.id,
    required this.authorName,
    required this.authorAvatarUrl,
    required this.content,
    required this.timestamp,
    this.likes = 0,
    this.replies = 0,
    this.mediaUrl,
    this.mediaType,
  });

  static const String rageThreadSeedKey =
      '7b3f3fcfe1124ba69c0708d4343f42ea:hh-rage';

  static String buildThreadKey({
    required String genreId,
    required String subGenreId,
  }) {
    return '$genreId:$subGenreId';
  }

  static List<Post> postsForThread({
    required String genreId,
    required String subGenreId,
  }) {
    final threadKey = buildThreadKey(
      genreId: genreId,
      subGenreId: subGenreId,
    );

    return List<Post>.unmodifiable(
      _seededThreadPosts[threadKey] ?? const <Post>[],
    );
  }

  /// Sample discussion posts for the Rage Thread.
  static List<Post> get sampleRagePosts => [
        Post(
          id: 'p1',
          authorName: 'WRLD_999',
          authorAvatarUrl: 'https://i.pravatar.cc/150?img=1',
          content:
              'Rage beats hit different at 3 AM. Who else is running Yeat on repeat? 🔥',
          timestamp: DateTime(2026, 3, 4, 3, 12),
          likes: 247,
          replies: 34,
        ),
        Post(
          id: 'p2',
          authorName: 'BassDemon',
          authorAvatarUrl: 'https://i.pravatar.cc/150?img=2',
          content:
              'The 808 distortion on this beat is insane. Producer tag anyone?',
          timestamp: DateTime(2026, 3, 4, 3, 45),
          likes: 89,
          replies: 12,
          mediaUrl: 'https://example.com/audio/rage-beat-01.mp3',
          mediaType: PostMediaType.audio,
        ),
        Post(
          id: 'p3',
          authorName: 'VibeCurator',
          authorAvatarUrl: 'https://i.pravatar.cc/150?img=3',
          content:
              'Rage is basically the punk of hip-hop. Fight me. 💀',
          timestamp: DateTime(2026, 3, 4, 4, 10),
          likes: 412,
          replies: 67,
        ),
        Post(
          id: 'p4',
          authorName: 'NightOwl808',
          authorAvatarUrl: 'https://i.pravatar.cc/150?img=4',
          content:
              'Just dropped a new rage instrumental. Link in bio. Need honest feedback 🎧',
          timestamp: DateTime(2026, 3, 4, 5, 22),
          likes: 56,
          replies: 8,
          mediaUrl:
              'https://images.unsplash.com/photo-1511379938547-c1f69419868d?w=400',
          mediaType: PostMediaType.image,
        ),
        Post(
          id: 'p5',
          authorName: 'SteppeRider',
          authorAvatarUrl: 'https://i.pravatar.cc/150?img=5',
          content:
              'What if rage beats met throat singing? Central Asian rage sub-genre when??',
          timestamp: DateTime(2026, 3, 4, 6, 55),
          likes: 1024,
          replies: 143,
        ),
      ];

  static Map<String, List<Post>> get _seededThreadPosts => {
        rageThreadSeedKey: sampleRagePosts,
      };
}

enum PostMediaType { audio, image, video }
