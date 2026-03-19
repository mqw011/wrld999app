import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../core/design/app_tokens.dart';
import '../models/genre.dart';
import '../providers/navigation_provider.dart';
import '../providers/theme_manager.dart';
import '../widgets/breadcrumb_widget.dart';

class GenrePage extends StatelessWidget {
  static const Color _baseBg = Color(0xFF0A0A0F);

  final Genre genre;

  const GenrePage({super.key, required this.genre});

  @override
  Widget build(BuildContext context) {
    final ThemeManager tm = context.watch<ThemeManager>();
    final NavigationProvider nav = context.read<NavigationProvider>();
    final Color onSurface = tm.themeData.colorScheme.onSurface;

    return Scaffold(
      backgroundColor: _baseBg,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  genre.primaryAccent.withValues(alpha: AppTokens.opacityDivider),
                  _baseBg,
                  _baseBg,
                ],
              ),
            ),
          ),
          CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                pinned: true,
                stretch: true,
                backgroundColor: _baseBg,
                expandedHeight: AppTokens.space2XL * (AppTokens.spaceMDPlus / AppTokens.spaceXS),
                leading: Padding(
                  padding: const EdgeInsets.only(left: AppTokens.spaceSMPlus),
                  child: IconButton(
                    onPressed: () {
                      tm.setActiveGenre(null);
                      nav.goBack();
                    },
                    icon: Container(
                      padding: const EdgeInsets.all(AppTokens.spaceSM),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: onSurface.withValues(alpha: AppTokens.opacityDivider),
                        border: Border.all(
                          color: onSurface.withValues(alpha: AppTokens.opacityChipBorder),
                        ),
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        size: AppTokens.iconSM + AppTokens.spaceXXS,
                        color: onSurface,
                      ),
                    ),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: _GenreHero(genre: genre),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppTokens.spaceLG,
                    AppTokens.spaceMD,
                    AppTokens.spaceLG,
                    AppTokens.spaceSMPlus,
                  ),
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
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppTokens.spaceLG),
                  child: Wrap(
                    spacing: AppTokens.spaceSM,
                    runSpacing: AppTokens.spaceSM,
                    children: genre.tags
                        .map(
                          (String tag) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppTokens.spaceSMPlus,
                              vertical: AppTokens.spaceXS,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(AppTokens.radiusFull),
                              color: genre.primaryAccent.withValues(alpha: AppTokens.opacityChipBorder),
                              border: Border.all(
                                color: genre.primaryAccent.withValues(
                                  alpha: AppTokens.opacityTextSubtle,
                                ),
                              ),
                            ),
                            child: Text(
                              '#$tag',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: AppTokens.textXS,
                                fontWeight: FontWeight.w600,
                                color: onSurface,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppTokens.spaceLG,
                    AppTokens.spaceLG,
                    AppTokens.spaceLG,
                    AppTokens.spaceMD,
                  ),
                  child: Text(
                    'Sub-genres',
                    style: GoogleFonts.sora(
                      fontSize: AppTokens.text2XL,
                      fontWeight: FontWeight.w700,
                      color: onSurface,
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppTokens.spaceLG),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      final SubGenre subGenre = genre.subGenres[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppTokens.spaceSMPlus),
                        child: _SubGenreCard(genre: genre, subGenre: subGenre),
                      );
                    },
                    childCount: genre.subGenres.length,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppTokens.spaceLG,
                    AppTokens.spaceLG,
                    AppTokens.spaceLG,
                    AppTokens.spaceMD,
                  ),
                  child: Text(
                    'Live Discussions',
                    style: GoogleFonts.sora(
                      fontSize: AppTokens.text2XL,
                      fontWeight: FontWeight.w700,
                      color: onSurface,
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppTokens.spaceLG,
                  AppTokens.elevationNone,
                  AppTokens.spaceLG,
                  AppTokens.space2XL,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    <Widget>[
                      _DiscussionCard(
                        title: 'Now Playing In ${genre.name}',
                        subtitle: 'Join the hottest thread and discover what the community is looping tonight.',
                        accent: genre.primaryAccent,
                        onTap: () {
                          if (genre.subGenres.isEmpty) {
                            return;
                          }
                          nav.navigateToSubGenre(genre.subGenres.first);
                          nav.navigateToDiscussion();
                        },
                      ),
                      const SizedBox(height: AppTokens.spaceSMPlus),
                      _DiscussionCard(
                        title: 'Producer Exchange',
                        subtitle: 'Share rough ideas, flips and edits. Instant feedback from genre insiders.',
                        accent: genre.secondaryAccent,
                        onTap: () {
                          if (genre.subGenres.isEmpty) {
                            return;
                          }
                          nav.navigateToSubGenre(genre.subGenres.first);
                          nav.navigateToDiscussion();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GenreHero extends StatelessWidget {
  final Genre genre;

  const _GenreHero({required this.genre});

  @override
  Widget build(BuildContext context) {
    final Color onSurface = Theme.of(context).colorScheme.onSurface;

    return Hero(
      tag: 'genre-cover-${genre.id}',
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          CachedNetworkImage(
            imageUrl: genre.imageUrl,
            fit: BoxFit.cover,
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  genre.primaryAccent.withValues(alpha: AppTokens.opacityDivider),
                  _GenrePagePalette.base.withValues(alpha: AppTokens.opacityTextSubtle),
                  _GenrePagePalette.base,
                ],
              ),
            ),
          ),
          Positioned(
            left: AppTokens.spaceLG,
            right: AppTokens.spaceLG,
            bottom: AppTokens.spaceLG,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(AppTokens.spaceSMPlus),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppTokens.radiusLG),
                    color: genre.primaryAccent.withValues(alpha: AppTokens.opacityChipBorder),
                    border: Border.all(
                      color: genre.primaryAccent.withValues(alpha: AppTokens.opacityTextSubtle),
                    ),
                  ),
                  child: Icon(
                    genre.icon,
                    size: AppTokens.iconMD + AppTokens.spaceXS,
                    color: onSurface,
                  ),
                ),
                const SizedBox(width: AppTokens.spaceSMPlus),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        genre.name,
                        style: GoogleFonts.sora(
                          fontSize: AppTokens.text4XL,
                          fontWeight: FontWeight.w800,
                          color: onSurface,
                          height: AppTokens.spaceSMPlus / AppTokens.spaceSM,
                        ),
                      ),
                      const SizedBox(height: AppTokens.spaceXS),
                      Text(
                        genre.description,
                        maxLines: AppTokens.spaceXXS.toInt(),
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: AppTokens.textSM,
                          fontWeight: FontWeight.w500,
                          color: onSurface.withValues(alpha: AppTokens.opacityTextSubtle),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SubGenreCard extends StatelessWidget {
  final Genre genre;
  final SubGenre subGenre;

  const _SubGenreCard({required this.genre, required this.subGenre});

  @override
  Widget build(BuildContext context) {
    final NavigationProvider nav = context.read<NavigationProvider>();
    final Color onSurface = Theme.of(context).colorScheme.onSurface;

    return GestureDetector(
      onTap: () => nav.navigateToSubGenre(subGenre),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTokens.radiusLG),
          color: onSurface.withValues(alpha: AppTokens.opacityDivider),
          border: Border.all(
            color: genre.primaryAccent.withValues(alpha: AppTokens.opacityChipBorder),
          ),
        ),
        padding: const EdgeInsets.all(AppTokens.spaceSMPlus),
        child: Row(
          children: <Widget>[
            Container(
              width: AppTokens.space2XL + AppTokens.spaceSM,
              height: AppTokens.space2XL + AppTokens.spaceSM,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppTokens.radiusMD),
                gradient: LinearGradient(
                  colors: <Color>[
                    genre.primaryAccent.withValues(alpha: AppTokens.opacityTextSubtle),
                    genre.secondaryAccent.withValues(alpha: AppTokens.opacityDivider),
                  ],
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: subGenre.imageUrl.isEmpty
                  ? Icon(
                      genre.icon,
                      color: onSurface,
                      size: AppTokens.iconMD + AppTokens.spaceXXS,
                    )
                  : CachedNetworkImage(
                      imageUrl: subGenre.imageUrl,
                      fit: BoxFit.cover,
                    ),
            ),
            const SizedBox(width: AppTokens.spaceSMPlus),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    subGenre.name,
                    style: GoogleFonts.sora(
                      fontSize: AppTokens.textMDPlus,
                      fontWeight: FontWeight.w700,
                      color: onSurface,
                    ),
                  ),
                  const SizedBox(height: AppTokens.spaceXS),
                  Text(
                    subGenre.description,
                    maxLines: AppTokens.spaceXXS.toInt(),
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: AppTokens.textSM,
                      color: onSurface.withValues(alpha: AppTokens.opacityTextSubtle),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward,
              size: AppTokens.iconSM + AppTokens.spaceXXS,
              color: genre.primaryAccent,
            ),
          ],
        ),
      ),
    );
  }
}

class _DiscussionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color accent;
  final VoidCallback onTap;

  const _DiscussionCard({
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color onSurface = Theme.of(context).colorScheme.onSurface;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTokens.radiusLG),
          color: onSurface.withValues(alpha: AppTokens.opacityDivider),
          border: Border.all(color: accent.withValues(alpha: AppTokens.opacityTextSubtle)),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: accent.withValues(alpha: AppTokens.opacityDivider),
              blurRadius: AppTokens.spaceMDPlus,
              spreadRadius: AppTokens.spaceXXS,
            ),
          ],
        ),
        padding: const EdgeInsets.all(AppTokens.spaceMD),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: AppTokens.spaceSM,
              height: AppTokens.spaceSM,
              margin: const EdgeInsets.only(top: AppTokens.spaceXS),
              decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
            ),
            const SizedBox(width: AppTokens.spaceSMPlus),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: GoogleFonts.sora(
                      fontSize: AppTokens.textMD,
                      fontWeight: FontWeight.w700,
                      color: onSurface,
                    ),
                  ),
                  const SizedBox(height: AppTokens.spaceXS),
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: AppTokens.textSM,
                      color: onSurface.withValues(alpha: AppTokens.opacityTextSubtle),
                      height: AppTokens.lineHeightRelaxed,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: AppTokens.iconMD, color: accent),
          ],
        ),
      ),
    );
  }
}

class _GenrePagePalette {
  static const Color base = Color(0xFF0A0A0F);
}
