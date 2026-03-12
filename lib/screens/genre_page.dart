import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/genre.dart';
import '../providers/navigation_provider.dart';
import '../providers/theme_manager.dart';
import '../widgets/breadcrumb_widget.dart';

/// Unified Genre Page template.
/// Accepts a [Genre] model and renders the correct accent colors, sub-genres,
/// tags, and header imagery.
///
/// Stitch IDs served by this template:
///   Hip-Hop:     7b3f3fcfe1124ba69c0708d4343f42ea
///   K-Pop:       8604e81115b149ceb71f6c66a3af4188
///   Jazz:        c3815d01b42b4905b54c792301d85ff3
///   Traditional: aea330f9577b43e8831ab3bedab5c8ef
///   Electronic:  3f573ca1...
///   Rock/Metal:  903d06c2...
class GenrePage extends StatelessWidget {
  final Genre genre;
  const GenrePage({super.key, required this.genre});

  @override
  Widget build(BuildContext context) {
    final tm = context.watch<ThemeManager>();
    final nav = context.read<NavigationProvider>();
    final featuredSubGenre =
        genre.subGenres.isNotEmpty ? genre.subGenres.first : null;

    return Scaffold(
      backgroundColor: tm.scaffoldBg,
      body: CustomScrollView(
        slivers: [
          // ── Hero header ────────────────────────────────────
          SliverAppBar(
            pinned: true,
            expandedHeight: 260,
            backgroundColor: tm.scaffoldBg,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 18),
              onPressed: () {
                tm.setActiveGenre(null);
                nav.goBack();
              },
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: _HeroHeader(genre: genre),
            ),
          ),

          // ── Breadcrumb ─────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: BreadcrumbBar.fromGenre(
                genre: genre,
                accentColor: genre.primaryAccent,
                onHomeTap: () {
                  tm.setActiveGenre(null);
                  nav.navigateToExplore();
                },
              ),
            ),
          ),

          // ── Tags row ───────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: genre.tags.map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: genre.primaryAccent.withValues(alpha: 0.12),
                      border: Border.all(
                        color: genre.primaryAccent.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Text(
                      '#$tag',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: genre.primaryAccent,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // ── Sub-genres header ──────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      color: genre.primaryAccent,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Sub-genres',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Sub-genre list ─────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _SubGenreCard(
                  subGenre: genre.subGenres[index],
                  genre: genre,
                ),
                childCount: genre.subGenres.length,
              ),
            ),
          ),

          // ── Discussions section ────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 32, 20, 12),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      color: genre.secondaryAccent,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Active Discussions',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _DiscussionPreviewCard(
                  title: featuredSubGenre == null
                      ? '🔥 Community Thread'
                      : '🔥 ${featuredSubGenre.name} Thread',
                  subtitle: featuredSubGenre == null
                      ? 'Open the first live conversation for this genre.'
                      : '${featuredSubGenre.description} — live now',
                  accentColor: genre.primaryAccent,
                  onTap: featuredSubGenre == null
                      ? () {}
                      : () {
                          nav.navigateToSubGenre(featuredSubGenre);
                          nav.navigateToDiscussion();
                        },
                ),
                const SizedBox(height: 10),
                _DiscussionPreviewCard(
                  title: '💿 New Releases',
                  subtitle:
                      'What dropped this week — 67 replies',
                  accentColor: genre.secondaryAccent,
                  onTap: () {},
                ),
                const SizedBox(height: 10),
                _DiscussionPreviewCard(
                  title: '🎤 Producer Corner',
                  subtitle: 'Share beats & get feedback — 92 replies',
                  accentColor: genre.primaryAccent.withValues(alpha: 0.7),
                  onTap: () {},
                ),
              ]),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

// ── Hero header with gradient & genre info ───────────────────
class _HeroHeader extends StatelessWidget {
  final Genre genre;
  const _HeroHeader({required this.genre});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CachedNetworkImage(
          imageUrl: genre.imageUrl,
          fit: BoxFit.cover,
          placeholder: (_, _) => Container(
            color: genre.primaryAccent.withValues(alpha: 0.15),
          ),
          errorWidget: (_, _, _) => Container(
            color: genre.primaryAccent.withValues(alpha: 0.15),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.3),
                genre.primaryAccent.withValues(alpha: 0.15),
                const Color(0xFF0D0D0D),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        ),
        Positioned(
          left: 20,
          right: 20,
          bottom: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: genre.primaryAccent.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      genre.icon,
                      color: genre.primaryAccent,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          genre.name,
                          style: GoogleFonts.inter(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          genre.description,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: Colors.white60,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Sub-genre card ───────────────────────────────────────────
class _SubGenreCard extends StatelessWidget {
  final SubGenre subGenre;
  final Genre genre;

  const _SubGenreCard({required this.subGenre, required this.genre});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () {
          final nav = context.read<NavigationProvider>();
          nav.navigateToSubGenre(subGenre);
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: const Color(0xFF1A1A1A),
            border: Border.all(
              color: genre.primaryAccent.withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            children: [
              // Thumbnail
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [
                      genre.primaryAccent.withValues(alpha: 0.3),
                      genre.secondaryAccent.withValues(alpha: 0.15),
                    ],
                  ),
                ),
                child: subGenre.imageUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: subGenre.imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, _) => const SizedBox(),
                          errorWidget: (_, _, _) => Icon(
                            genre.icon,
                            color: genre.primaryAccent,
                            size: 24,
                          ),
                        ),
                      )
                    : Icon(genre.icon,
                        color: genre.primaryAccent, size: 24),
              ),
              const SizedBox(width: 14),
              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subGenre.name,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subGenre.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white54,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: genre.primaryAccent.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Discussion preview card ──────────────────────────────────
class _DiscussionPreviewCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color accentColor;
  final VoidCallback onTap;

  const _DiscussionPreviewCard({
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: accentColor.withValues(alpha: 0.08),
          border: Border.all(
            color: accentColor.withValues(alpha: 0.15),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: accentColor,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
