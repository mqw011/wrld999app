// Place this file in: lib/models/user.dart

class User {
  final String username;
  final String bio;
  final List<String> favoriteGenreIds;
  final DateTime joinedAt;
  final String? lastThreadKey;

  const User({
    required this.username,
    required this.bio,
    required this.favoriteGenreIds,
    required this.joinedAt,
    this.lastThreadKey,
  });

  factory User.initial() {
    return User(
      username: 'WRLD_USER',
      bio: 'Music is where worlds collide.',
      favoriteGenreIds: const <String>[],
      joinedAt: DateTime.now(),
      lastThreadKey: null,
    );
  }

  User copyWith({
    String? username,
    String? bio,
    List<String>? favoriteGenreIds,
    DateTime? joinedAt,
    String? lastThreadKey,
    bool clearLastThreadKey = false,
  }) {
    return User(
      username: username ?? this.username,
      bio: bio ?? this.bio,
      favoriteGenreIds: favoriteGenreIds ?? this.favoriteGenreIds,
      joinedAt: joinedAt ?? this.joinedAt,
      lastThreadKey: clearLastThreadKey
          ? null
          : (lastThreadKey ?? this.lastThreadKey),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'bio': bio,
      'favoriteGenreIds': favoriteGenreIds,
      'joinedAt': joinedAt.toIso8601String(),
      'lastThreadKey': lastThreadKey,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    final rawGenres = json['favoriteGenreIds'];

    return User(
      username: json['username'] as String? ?? 'WRLD_USER',
      bio: json['bio'] as String? ?? 'Music is where worlds collide.',
      favoriteGenreIds: rawGenres is List
          ? rawGenres.whereType<String>().toList(growable: false)
          : const <String>[],
      joinedAt:
          DateTime.tryParse(json['joinedAt'] as String? ?? '') ??
          DateTime.now(),
      lastThreadKey: json['lastThreadKey'] as String?,
    );
  }
}
