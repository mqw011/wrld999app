// Place this file in: lib/screens/account_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/genre.dart';
import '../providers/navigation_provider.dart';
import '../providers/post_provider.dart';
import '../providers/theme_manager.dart';
import '../providers/user_provider.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeManager = context.watch<ThemeManager>();
    final navigationProvider = context.read<NavigationProvider>();
    final userProvider = context.watch<UserProvider>();
    final postProvider = context.watch<PostProvider>();
    final user = userProvider.user;
    final favoriteGenres = _favoriteGenres(user.favoriteGenreIds);
    final postCount = _countUserPosts(postProvider);

    return Scaffold(
      backgroundColor: themeManager.scaffoldBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _AccountHeader(
                username: user.username,
                bio: user.bio,
                joinedAt: user.joinedAt,
                accentColor: themeManager.primaryAccent,
              ),
              const SizedBox(height: 20),
              _StatsRow(
                postCount: postCount,
                favoriteGenreCount: favoriteGenres.length,
                accentColor: themeManager.primaryAccent,
              ),
              const SizedBox(height: 24),
              Text(
                'Favorite genres',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 48,
                child: favoriteGenres.isEmpty
                    ? _EmptyGenresHint(accentColor: themeManager.primaryAccent)
                    : ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: favoriteGenres.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          final genre = favoriteGenres[index];
                          return _GenreChip(genre: genre);
                        },
                      ),
              ),
              const SizedBox(height: 28),
              _ActionButton(
                label: 'Edit profile',
                icon: Icons.edit_outlined,
                accentColor: themeManager.primaryAccent,
                onPressed: navigationProvider.goToEditProfile,
              ),
              const SizedBox(height: 12),
              _ActionButton(
                label: 'Discussions',
                icon: Icons.forum_outlined,
                accentColor: themeManager.secondaryAccent,
                onPressed: navigationProvider.goToLastThread,
              ),
              const SizedBox(height: 12),
              _ActionButton(
                label: 'Reset genres',
                icon: Icons.restart_alt,
                accentColor: Colors.white54,
                isDanger: true,
                onPressed: () async {
                  await userProvider.resetOnboarding();
                  navigationProvider.goToOnboarding();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Genre> _favoriteGenres(List<String> favoriteGenreIds) {
    final genresById = {
      for (final genre in Genre.allGenres) genre.id: genre,
    };

    return favoriteGenreIds
        .map((genreId) => genresById[genreId])
        .whereType<Genre>()
        .toList(growable: false);
  }

  int _countUserPosts(PostProvider postProvider) {
    var count = 0;

    for (final genre in Genre.allGenres) {
      for (final subGenre in genre.subGenres) {
        final posts = postProvider.postsForThread(
          genreId: genre.id,
          subGenreId: subGenre.id,
        );
        count += posts.where((post) => post.authorName == 'You').length;
      }
    }

    return count;
  }
}

class _AccountHeader extends StatelessWidget {
  final String username;
  final String bio;
  final DateTime joinedAt;
  final Color accentColor;

  const _AccountHeader({
    required this.username,
    required this.bio,
    required this.joinedAt,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _AvatarBadge(username: username, accentColor: accentColor),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      username,
                      style: GoogleFonts.sora(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      bio,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.white70,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Joined ${_formatJoinedAt(joinedAt)}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white38,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatJoinedAt(DateTime value) {
    const monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final month = monthNames[value.month - 1];
    return '$month ${value.year}';
  }
}

class _AvatarBadge extends StatelessWidget {
  final String username;
  final Color accentColor;

  const _AvatarBadge({required this.username, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 82,
      height: 82,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            accentColor.withValues(alpha: 0.95),
            accentColor.withValues(alpha: 0.45),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.25),
            blurRadius: 24,
            spreadRadius: 1,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        _initials(username),
        style: GoogleFonts.sora(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: -0.5,
        ),
      ),
    );
  }

  String _initials(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return 'WR';
    }

    final parts = trimmed
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList(growable: false);
    if (parts.isEmpty) {
      return trimmed.substring(0, trimmed.length.clamp(0, 2)).toUpperCase();
    }
    if (parts.length == 1) {
      final word = parts.first;
      return word.substring(0, word.length.clamp(0, 2)).toUpperCase();
    }

    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}

class _StatsRow extends StatelessWidget {
  final int postCount;
  final int favoriteGenreCount;
  final Color accentColor;

  const _StatsRow({
    required this.postCount,
    required this.favoriteGenreCount,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Posts',
            value: postCount.toString(),
            accentColor: accentColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: 'Favorite genres',
            value: favoriteGenreCount.toString(),
            accentColor: accentColor,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color accentColor;

  const _StatCard({
    required this.label,
    required this.value,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: GoogleFonts.sora(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: accentColor,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }
}

class _GenreChip extends StatelessWidget {
  final Genre genre;

  const _GenreChip({required this.genre});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: genre.primaryAccent.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: genre.primaryAccent.withValues(alpha: 0.32)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(genre.icon, size: 16, color: genre.primaryAccent),
          const SizedBox(width: 8),
          Text(
            genre.name,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyGenresHint extends StatelessWidget {
  final Color accentColor;

  const _EmptyGenresHint({required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accentColor.withValues(alpha: 0.12)),
      ),
      child: Text(
        'No favorite genres yet',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Colors.white54,
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onPressed;
  final bool isDanger;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.accentColor,
    required this.onPressed,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18, color: isDanger ? Colors.white70 : accentColor),
        label: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: isDanger ? Colors.white : Colors.white,
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: isDanger
              ? Colors.white.withValues(alpha: 0.04)
              : accentColor.withValues(alpha: 0.08),
          side: BorderSide(
            color: isDanger
                ? Colors.white.withValues(alpha: 0.12)
                : accentColor.withValues(alpha: 0.24),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }
}
