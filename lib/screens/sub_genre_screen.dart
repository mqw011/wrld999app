import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/genre.dart';
import '../providers/navigation_provider.dart';
import '../providers/theme_manager.dart';
import '../widgets/breadcrumb_widget.dart';

class SubGenreScreen extends StatelessWidget {
  final Genre genre;
  final SubGenre subGenre;

  const SubGenreScreen({
    super.key,
    required this.genre,
    required this.subGenre,
  });

  @override
  Widget build(BuildContext context) {
    final tm = context.watch<ThemeManager>();
    final nav = context.read<NavigationProvider>();

    return Scaffold(
      backgroundColor: tm.scaffoldBg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 250,
            backgroundColor: tm.scaffoldBg,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 18),
              onPressed: nav.goBack,
            ),
            actions: [
              IconButton(
                onPressed: nav.navigateToDiscussion,
                icon: Icon(Icons.forum, color: genre.primaryAccent),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _SubGenreHero(
                genre: genre,
                subGenre: subGenre,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: BreadcrumbBar.fromGenre(
                genre: genre,
                subGenreName: subGenre.name,
                accentColor: genre.primaryAccent,
                onHomeTap: () {
                  tm.setActiveGenre(null);
                  nav.navigateToExplore();
                },
                onGenreTap: () => nav.goBack(),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: _InfoCard(
                title: 'About this sound',
                child: Text(
                  subGenre.description,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.white70,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: _InfoCard(
                title: 'Sound DNA',
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: genre.tags.take(4).map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: genre.primaryAccent.withValues(alpha: 0.12),
                        border: Border.all(
                          color: genre.primaryAccent.withValues(alpha: 0.22),
                        ),
                      ),
                      child: Text(
                        '#$tag',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: genre.primaryAccent,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Text(
                'Jump into the conversation',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _ThreadEntryCard(
                  title: 'Open ${subGenre.name} Thread',
                  subtitle: 'See the live discussion feed for this sub-genre.',
                  accentColor: genre.primaryAccent,
                  icon: Icons.local_fire_department,
                  onTap: nav.navigateToDiscussion,
                ),
                const SizedBox(height: 12),
                _ThreadEntryCard(
                  title: 'Producer Corner',
                  subtitle: 'Share beats, edits, and production ideas.',
                  accentColor: genre.secondaryAccent,
                  icon: Icons.graphic_eq,
                  onTap: nav.navigateToDiscussion,
                ),
                const SizedBox(height: 12),
                _ThreadEntryCard(
                  title: 'Scene Check-In',
                  subtitle: 'Talk trends, releases, and who is defining the sound.',
                  accentColor: genre.primaryAccent.withValues(alpha: 0.85),
                  icon: Icons.trending_up,
                  onTap: nav.navigateToDiscussion,
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

class _SubGenreHero extends StatelessWidget {
  final Genre genre;
  final SubGenre subGenre;

  const _SubGenreHero({
    required this.genre,
    required this.subGenre,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CachedNetworkImage(
          imageUrl: subGenre.imageUrl.isNotEmpty ? subGenre.imageUrl : genre.imageUrl,
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
                Colors.black.withValues(alpha: 0.28),
                genre.primaryAccent.withValues(alpha: 0.18),
                const Color(0xFF0D0D0D),
              ],
              stops: const [0.0, 0.55, 1.0],
            ),
          ),
        ),
        Positioned(
          left: 20,
          right: 20,
          bottom: 24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.24),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                ),
                child: Text(
                  genre.name.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: Colors.white70,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                subGenre.name,
                style: GoogleFonts.inter(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Dedicated hub for ${subGenre.name.toLowerCase()} fans inside ${genre.name}.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.white70,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _InfoCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFF171717),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _ThreadEntryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color accentColor;
  final IconData icon;
  final VoidCallback onTap;

  const _ThreadEntryCard({
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: const Color(0xFF171717),
          border: Border.all(
            color: accentColor.withValues(alpha: 0.18),
          ),
          gradient: LinearGradient(
            colors: [
              accentColor.withValues(alpha: 0.12),
              accentColor.withValues(alpha: 0.03),
            ],
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: accentColor.withValues(alpha: 0.18),
              ),
              child: Icon(icon, color: accentColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.white60,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: accentColor),
          ],
        ),
      ),
    );
  }
}