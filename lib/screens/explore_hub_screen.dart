import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../data/local_search_history_data_source.dart';
import '../models/genre.dart';
import '../providers/navigation_provider.dart';
import '../providers/theme_manager.dart';

/// Stitch ID: 230ba0db19084b93a09a9be3d57e931a
/// Main Explore Hub — grid/list of genre hubs.
class ExploreHubScreen extends StatefulWidget {
  const ExploreHubScreen({super.key});

  @override
  State<ExploreHubScreen> createState() => _ExploreHubScreenState();
}

class _ExploreHubScreenState extends State<ExploreHubScreen> {
  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;
  late final SearchHistoryDataSource _searchHistoryDataSource;
  String _searchQuery = '';
  List<String> _searchHistory = [];
  bool _isSearchHistoryLoaded = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();
    _searchHistoryDataSource = LocalSearchHistoryDataSource();
    _loadSearchHistory();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadSearchHistory() async {
    final loadedHistory = await _searchHistoryDataSource.loadSearchHistory();
    if (!mounted) {
      return;
    }

    setState(() {
      _searchHistory = loadedHistory.take(5).toList(growable: false);
      _isSearchHistoryLoaded = true;
    });
  }

  Future<void> _submitSearch(String rawQuery) async {
    final query = rawQuery.trim();
    if (query.isEmpty) {
      return;
    }

    if (_searchController.text != query) {
      _searchController.value = TextEditingValue(
        text: query,
        selection: TextSelection.collapsed(offset: query.length),
      );
    }

    setState(() {
      _searchQuery = query;
    });

    await _saveSearchHistory(query);
  }

  Future<void> _saveSearchHistory(String query) async {
    final normalizedQuery = query.toLowerCase();
    final updatedHistory = <String>[
      query,
      ..._searchHistory.where(
        (historyItem) => historyItem.toLowerCase() != normalizedQuery,
      ),
    ].take(5).toList(growable: false);

    setState(() {
      _searchHistory = updatedHistory;
      _isSearchHistoryLoaded = true;
    });

    await _searchHistoryDataSource.saveSearchHistory(updatedHistory);
  }

  Future<void> _removeSearchHistoryItem(String query) async {
    final normalizedQuery = query.toLowerCase();
    final updatedHistory = _searchHistory
        .where((historyItem) => historyItem.toLowerCase() != normalizedQuery)
        .toList(growable: false);

    setState(() {
      _searchHistory = updatedHistory;
      _isSearchHistoryLoaded = true;
    });

    await _searchHistoryDataSource.saveSearchHistory(updatedHistory);
  }

  Future<void> _reuseSearchHistoryItem(String query) async {
    _searchFocusNode.requestFocus();
    await _submitSearch(query);
  }

  @override
  Widget build(BuildContext context) {
    final tm = context.watch<ThemeManager>();
    final genres = Genre.allGenres;
    final normalizedQuery = _searchQuery.trim().toLowerCase();
    final filteredGenres = normalizedQuery.isEmpty
        ? genres
        : genres
            .where(
              (genre) => genre.name.toLowerCase().contains(normalizedQuery),
            )
            .toList();
    final isSearching = normalizedQuery.isNotEmpty;

    return Scaffold(
      backgroundColor: tm.scaffoldBg,
      body: CustomScrollView(
        slivers: [
          // ── App bar ────────────────────────────────────────
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: tm.scaffoldBg,
            expandedHeight: 120,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding:
                  const EdgeInsets.only(left: 20, bottom: 16),
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '999',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'MUSIC HUB',
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: Colors.white54,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                onPressed: () => _searchFocusNode.requestFocus(),
                icon: const Icon(Icons.search, color: Colors.white70),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.tune, color: Colors.white70),
              ),
              const SizedBox(width: 8),
            ],
          ),

          // ── Section header ─────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isSearching ? 'Search Results' : 'Explore Genres',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF171717),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      textInputAction: TextInputAction.search,
                      onSubmitted: _submitSearch,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search genre by name…',
                        hintStyle: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.white38,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.white54,
                        ),
                        suffixIcon: isSearching
                            ? IconButton(
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                },
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white54,
                                ),
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),
                  if (_isSearchHistoryLoaded && _searchHistory.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Text(
                      'Search History',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white70,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 42,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _searchHistory.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          final query = _searchHistory[index];
                          return _SearchHistoryChip(
                            query: query,
                            accentColor: tm.primaryAccent,
                            backgroundColor: tm.cardColor,
                            onTap: () => _reuseSearchHistoryItem(query),
                            onDelete: () => _removeSearchHistoryItem(query),
                          );
                        },
                      ),
                    ),
                  ],
                  if (isSearching) ...[
                    const SizedBox(height: 10),
                    Text(
                      '${filteredGenres.length} result${filteredGenres.length == 1 ? '' : 's'} for "${_searchQuery.trim()}"',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          if (filteredGenres.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: const Color(0xFF171717),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.search_off,
                        color: Colors.white54,
                        size: 36,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No matching genres',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Try a different name like Hip-Hop, Jazz, or Rock.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Colors.white54,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // ── Genre grid ─────────────────────────────────────
          if (filteredGenres.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _GenreCard(genre: filteredGenres[index]),
                  childCount: filteredGenres.length,
                ),
              ),
            ),

          // ── Trending section ───────────────────────────────
          if (!isSearching) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 32, 20, 12),
                child: Text(
                  'Trending Now',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: SizedBox(
                height: 140,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: genres.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (context, index) =>
                      _TrendingCard(genre: genres[index]),
                ),
              ),
            ),
          ],

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

// ── Genre grid card ──────────────────────────────────────────
class _GenreCard extends StatelessWidget {
  final Genre genre;
  const _GenreCard({required this.genre});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<ThemeManager>().setActiveGenre(genre);
        context.read<NavigationProvider>().navigateToGenre(genre);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: const Color(0xFF1A1A1A),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image
            CachedNetworkImage(
              imageUrl: genre.imageUrl,
              fit: BoxFit.cover,
              placeholder: (_, _) => Container(
                color: genre.primaryAccent.withValues(alpha: 0.15),
              ),
              errorWidget: (_, _, _) => Container(
                color: genre.primaryAccent.withValues(alpha: 0.15),
                child: Icon(genre.icon,
                    size: 48, color: genre.primaryAccent.withValues(alpha: 0.4)),
              ),
            ),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.85),
                  ],
                  stops: const [0.3, 1.0],
                ),
              ),
            ),
            // Accent bar at top
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 3,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [genre.primaryAccent, genre.secondaryAccent],
                  ),
                ),
              ),
            ),
            // Content
            Positioned(
              left: 14,
              right: 14,
              bottom: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(genre.icon, color: genre.primaryAccent, size: 22),
                  const SizedBox(height: 8),
                  Text(
                    genre.name,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${genre.subGenres.length} sub-genres',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: Colors.white54,
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

// ── Trending horizontal card ─────────────────────────────────
class _TrendingCard extends StatelessWidget {
  final Genre genre;
  const _TrendingCard({required this.genre});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<ThemeManager>().setActiveGenre(genre);
        context.read<NavigationProvider>().navigateToGenre(genre);
      },
      child: Container(
        width: 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              genre.primaryAccent.withValues(alpha: 0.3),
              genre.secondaryAccent.withValues(alpha: 0.1),
            ],
          ),
          border: Border.all(
            color: genre.primaryAccent.withValues(alpha: 0.2),
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(genre.icon, color: genre.primaryAccent, size: 20),
                const SizedBox(width: 8),
                Icon(Icons.trending_up,
                    color: Colors.green.shade400, size: 16),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  genre.name,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  genre.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: Colors.white54,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchHistoryChip extends StatelessWidget {
  final String query;
  final Color accentColor;
  final Color backgroundColor;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _SearchHistoryChip({
    required this.query,
    required this.accentColor,
    required this.backgroundColor,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: accentColor.withValues(alpha: 0.18)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.history, size: 14, color: accentColor),
              const SizedBox(width: 8),
              Text(
                query,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.close, size: 14, color: Colors.white54),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(width: 22, height: 22),
                splashRadius: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
