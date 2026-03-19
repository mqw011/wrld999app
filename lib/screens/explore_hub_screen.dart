import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../core/design/app_tokens.dart';
import '../models/genre.dart';
import '../providers/navigation_provider.dart';
import '../providers/theme_manager.dart';

class ExploreHubScreen extends StatefulWidget {
  const ExploreHubScreen({super.key});

  @override
  State<ExploreHubScreen> createState() => _ExploreHubScreenState();
}

class _ExploreHubScreenState extends State<ExploreHubScreen> {
  static const Color _baseBg = Color(0xFF0A0A0F);

  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeManager tm = context.watch<ThemeManager>();
    final Color onSurface = tm.themeData.colorScheme.onSurface;
    final List<Genre> genres = Genre.allGenres;

    final String normalized = _searchQuery.trim().toLowerCase();
    final List<Genre> filteredGenres = normalized.isEmpty
        ? genres
        : genres
            .where((Genre genre) => genre.name.toLowerCase().contains(normalized))
            .toList();

    final bool isSearching = normalized.isNotEmpty;

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
                  tm.primaryAccent.withValues(alpha: AppTokens.opacityDivider),
                  _baseBg,
                  _baseBg,
                ],
              ),
            ),
          ),
          CustomScrollView(
            slivers: <Widget>[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppTokens.spaceLG,
                    AppTokens.space2XL,
                    AppTokens.spaceLG,
                    AppTokens.spaceLG,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Explore',
                        style: GoogleFonts.sora(
                          fontSize: AppTokens.text4XL,
                          fontWeight: FontWeight.w800,
                          color: onSurface,
                          letterSpacing: AppTokens.letterSpacingTight,
                        ),
                      ),
                      const SizedBox(height: AppTokens.spaceSM),
                      Text(
                        'A curated map of genres, communities and sonic worlds.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: AppTokens.textSM,
                          fontWeight: FontWeight.w500,
                          color: onSurface.withValues(alpha: AppTokens.opacityTextSubtle),
                          height: AppTokens.lineHeightRelaxed,
                        ),
                      ),
                      const SizedBox(height: AppTokens.spaceLG),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTokens.spaceMD,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppTokens.radiusXL),
                          color: onSurface.withValues(alpha: AppTokens.opacityDivider),
                          border: Border.all(
                            color: tm.primaryAccent.withValues(
                              alpha: AppTokens.opacityChipBorder,
                            ),
                          ),
                        ),
                        child: TextField(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          onChanged: (String value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: AppTokens.textMD,
                            fontWeight: FontWeight.w500,
                            color: onSurface,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Search by genre',
                            hintStyle: GoogleFonts.plusJakartaSans(
                              fontSize: AppTokens.textSM,
                              color: onSurface.withValues(
                                alpha: AppTokens.opacityTextSubtle,
                              ),
                            ),
                            icon: Icon(
                              Icons.search,
                              color: onSurface.withValues(
                                alpha: AppTokens.opacityTextSubtle,
                              ),
                              size: AppTokens.iconMD,
                            ),
                            suffixIcon: isSearching
                                ? IconButton(
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {
                                        _searchQuery = '';
                                      });
                                    },
                                    icon: Icon(
                                      Icons.close,
                                      color: onSurface.withValues(
                                        alpha: AppTokens.opacityTextSubtle,
                                      ),
                                      size: AppTokens.iconMD,
                                    ),
                                  )
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppTokens.spaceSMPlus),
                      Text(
                        isSearching
                            ? '${filteredGenres.length} match'
                            : '${genres.length} genres available',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: AppTokens.textXS,
                          fontWeight: FontWeight.w600,
                          color: onSurface.withValues(alpha: AppTokens.opacityTextSubtle),
                          letterSpacing: AppTokens.letterSpacingWide,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (!isSearching) ...<Widget>[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppTokens.spaceLG),
                    child: Text(
                      'Featured Hubs',
                      style: GoogleFonts.sora(
                        fontSize: AppTokens.textLG,
                        fontWeight: FontWeight.w700,
                        color: onSurface,
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: AppTokens.layoutExploreFeaturedSectionHeight,
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        AppTokens.spaceLG,
                        AppTokens.spaceMD,
                        AppTokens.spaceLG,
                        AppTokens.spaceLG,
                      ),
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (BuildContext context, int index) {
                        final Genre genre = genres[index];
                        return _FeaturedGenreCard(genre: genre);
                      },
                      separatorBuilder: (_, __) => const SizedBox(width: AppTokens.spaceMD),
                      itemCount: genres.length,
                    ),
                  ),
                ),
              ],
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppTokens.spaceLG),
                  child: Text(
                    isSearching ? 'Search Results' : 'All Genres',
                    style: GoogleFonts.sora(
                      fontSize: AppTokens.textLG,
                      fontWeight: FontWeight.w700,
                      color: onSurface,
                    ),
                  ),
                ),
              ),
              if (filteredGenres.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppTokens.spaceLG,
                      AppTokens.spaceMD,
                      AppTokens.spaceLG,
                      AppTokens.space2XL,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(AppTokens.spaceLG),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppTokens.radiusXL),
                        color: onSurface.withValues(alpha: AppTokens.opacityDivider),
                        border: Border.all(
                          color: onSurface.withValues(alpha: AppTokens.opacityChipBorder),
                        ),
                      ),
                      child: Column(
                        children: <Widget>[
                          Icon(
                            Icons.headphones,
                            size: AppTokens.iconLG,
                            color: onSurface.withValues(alpha: AppTokens.opacityTextSubtle),
                          ),
                          const SizedBox(height: AppTokens.spaceSMPlus),
                          Text(
                            'No genre found',
                            style: GoogleFonts.sora(
                              fontSize: AppTokens.textMDPlus,
                              fontWeight: FontWeight.w700,
                              color: onSurface,
                            ),
                          ),
                          const SizedBox(height: AppTokens.spaceXS),
                          Text(
                            'Try a different query like Jazz, Electronic or Hip-Hop.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: AppTokens.textSM,
                              color: onSurface.withValues(alpha: AppTokens.opacityTextSubtle),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppTokens.spaceLG,
                    AppTokens.spaceMD,
                    AppTokens.spaceLG,
                    AppTokens.space2XL,
                  ),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: AppTokens.layoutExploreGenreGridCrossAxisCount,
                      crossAxisSpacing: AppTokens.spaceSMPlus,
                      mainAxisSpacing: AppTokens.spaceSMPlus,
                      childAspectRatio: AppTokens.layoutExploreGenreGridAspectRatio,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        final Genre genre = filteredGenres[index];
                        return _GenreGridCard(genre: genre);
                      },
                      childCount: filteredGenres.length,
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

class _FeaturedGenreCard extends StatelessWidget {
  final Genre genre;

  const _FeaturedGenreCard({required this.genre});

  @override
  Widget build(BuildContext context) {
    final ThemeManager tm = context.read<ThemeManager>();
    final NavigationProvider nav = context.read<NavigationProvider>();
    final Color onSurface = Theme.of(context).colorScheme.onSurface;

    return GestureDetector(
      onTap: () {
        tm.setActiveGenre(genre);
        nav.navigateToGenre(genre);
      },
      child: Hero(
        tag: 'genre-cover-${genre.id}',
        child: Container(
          width: AppTokens.layoutExploreFeaturedCardWidth,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTokens.radiusXL),
            border: Border.all(
              color: genre.primaryAccent.withValues(alpha: AppTokens.opacityTextSubtle),
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: genre.primaryAccent.withValues(alpha: AppTokens.opacityTextSubtle),
                blurRadius: AppTokens.spaceLG,
                spreadRadius: AppTokens.spaceXXS,
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
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
                      const Color(0xFF0A0A0F).withValues(alpha: AppTokens.opacityTextSubtle),
                      const Color(0xFF0A0A0F),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: AppTokens.spaceMD,
                right: AppTokens.spaceMD,
                bottom: AppTokens.spaceMD,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Icon(genre.icon, color: genre.primaryAccent, size: AppTokens.iconMD),
                    const SizedBox(height: AppTokens.spaceSM),
                    Text(
                      genre.name,
                      maxLines: AppTokens.spaceXXS.toInt(),
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.sora(
                        fontSize: AppTokens.textLG,
                        fontWeight: FontWeight.w700,
                        color: onSurface,
                      ),
                    ),
                    const SizedBox(height: AppTokens.spaceXS),
                    Text(
                      genre.description,
                      maxLines: AppTokens.spaceXXS.toInt(),
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: AppTokens.textXS,
                        color: onSurface.withValues(alpha: AppTokens.opacityTextSubtle),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GenreGridCard extends StatelessWidget {
  final Genre genre;

  const _GenreGridCard({required this.genre});

  @override
  Widget build(BuildContext context) {
    final ThemeManager tm = context.read<ThemeManager>();
    final NavigationProvider nav = context.read<NavigationProvider>();
    final Color onSurface = Theme.of(context).colorScheme.onSurface;

    return GestureDetector(
      onTap: () {
        tm.setActiveGenre(genre);
        nav.navigateToGenre(genre);
      },
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
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            CachedNetworkImage(imageUrl: genre.imageUrl, fit: BoxFit.cover),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    genre.primaryAccent.withValues(alpha: AppTokens.opacityDivider),
                    const Color(0xFF0A0A0F).withValues(alpha: AppTokens.opacityTextSubtle),
                    const Color(0xFF0A0A0F),
                  ],
                ),
              ),
            ),
            Positioned(
              left: AppTokens.spaceSMPlus,
              right: AppTokens.spaceSMPlus,
              bottom: AppTokens.spaceSMPlus,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    genre.name,
                    maxLines: AppTokens.spaceXXS.toInt(),
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.sora(
                      fontSize: AppTokens.textMDPlus,
                      fontWeight: FontWeight.w700,
                      color: onSurface,
                    ),
                  ),
                  const SizedBox(height: AppTokens.spaceXS),
                  Text(
                    '${genre.subGenres.length} sub-genres',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: AppTokens.textXS,
                      color: onSurface.withValues(alpha: AppTokens.opacityTextSubtle),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
