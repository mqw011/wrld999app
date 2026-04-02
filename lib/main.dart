import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'models/genre.dart';
import 'models/post.dart';
import 'providers/post_provider.dart';
import 'providers/theme_manager.dart';
import 'providers/navigation_provider.dart';
import 'providers/user_provider.dart';
import 'screens/account_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/explore_hub_screen.dart';
import 'screens/genre_page.dart';
import 'screens/sub_genre_screen.dart';
import 'screens/discussion_thread_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0D0D0D),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const NineNineNineApp());
}

class NineNineNineApp extends StatelessWidget {
  const NineNineNineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeManager()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => PostProvider()),
      ],
      child: Consumer<ThemeManager>(
        builder: (context, themeManager, _) {
          return MaterialApp(
            title: '999 Music Hub',
            debugShowCheckedModeBanner: false,
            theme: themeManager.themeData,
            home: const AppShell(),
          );
        },
      ),
    );
  }
}

/// Root shell that switches screens based on [NavigationProvider] state.
/// Uses [AnimatedSwitcher] for smooth transitions.
class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavigationProvider>();
    final userProvider = context.watch<UserProvider>();

    return Consumer<ThemeManager>(
      builder: (context, tm, _) {
        return PopScope(
          canPop: !nav.canGoBack,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) nav.goBack();
          },
          child: nav.currentScreen == AppScreen.onboarding
              ? AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.04, 0),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: KeyedSubtree(
                    key: ValueKey(nav.currentScreen),
                    child: _buildScreen(nav, tm, userProvider),
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        switchInCurve: Curves.easeOut,
                        switchOutCurve: Curves.easeIn,
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0.04, 0),
                                end: Offset.zero,
                              ).animate(animation),
                              child: child,
                            ),
                          );
                        },
                        child: KeyedSubtree(
                          key: ValueKey(nav.currentScreen),
                          child: _buildScreen(nav, tm, userProvider),
                        ),
                      ),
                    ),
                    _buildBottomNavigationBar(context, nav, tm),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildScreen(
    NavigationProvider nav,
    ThemeManager tm,
    UserProvider userProvider,
  ) {
    switch (nav.currentScreen) {
      case AppScreen.onboarding:
        return const OnboardingScreen(key: ValueKey('onboarding'));

      case AppScreen.explore:
        return const ExploreHubScreen(key: ValueKey('explore'));

      case AppScreen.genre:
        if (nav.selectedGenre != null) {
          return GenrePage(
            key: ValueKey('genre-${nav.selectedGenre!.id}'),
            genre: nav.selectedGenre!,
          );
        }
        return const ExploreHubScreen(key: ValueKey('explore-fallback'));

      case AppScreen.subGenre:
        if (nav.selectedGenre != null && nav.selectedSubGenre != null) {
          return SubGenreScreen(
            key: ValueKey('subgenre-${nav.selectedSubGenre!.id}'),
            genre: nav.selectedGenre!,
            subGenre: nav.selectedSubGenre!,
          );
        }
        return const ExploreHubScreen(key: ValueKey('explore-fallback2'));

      case AppScreen.discussion:
        final resolvedThread = _resolveThread(nav, userProvider.user.lastThreadKey);
        if (resolvedThread != null) {
          return DiscussionThreadScreen(
            key: ValueKey('discussion-${resolvedThread.threadKey}'),
            genre: resolvedThread.genre,
            subGenre: resolvedThread.subGenre,
          );
        }
        return const ExploreHubScreen(key: ValueKey('explore-fallback3'));

      case AppScreen.account:
        return const AccountScreen(key: ValueKey('account'));

      case AppScreen.editProfile:
        return const EditProfileScreen(key: ValueKey('edit-profile'));
    }
  }

  Widget _buildBottomNavigationBar(
    BuildContext context,
    NavigationProvider nav,
    ThemeManager tm,
  ) {
    final currentIndex = switch (nav.currentScreen) {
      AppScreen.discussion => 1,
      AppScreen.account || AppScreen.editProfile => 2,
      _ => 0,
    };

    return TweenAnimationBuilder<Color?>(
      tween: ColorTween(end: tm.primaryAccent),
      duration: const Duration(milliseconds: 300),
      builder: (context, animatedAccent, _) {
        final accent = animatedAccent ?? tm.primaryAccent;

        return DecoratedBox(
          decoration: BoxDecoration(
            color: tm.scaffoldBg,
            border: Border(
              top: BorderSide(color: accent.withValues(alpha: 0.4)),
            ),
          ),
          child: BottomNavigationBar(
            currentIndex: currentIndex,
            selectedItemColor: accent,
            unselectedItemColor: Theme.of(context)
                .bottomNavigationBarTheme
                .unselectedItemColor,
            onTap: (index) {
              switch (index) {
                case 0:
                  nav.navigateToExplore();
                  break;
                case 1:
                  nav.goToLastThread();
                  break;
                case 2:
                  nav.goToAccount();
                  break;
              }
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.explore_outlined),
                activeIcon: Icon(Icons.explore),
                label: 'Explore',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.forum_outlined),
                activeIcon: Icon(Icons.forum),
                label: 'Discussions',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        );
      },
    );
  }

  _ResolvedThread? _resolveThread(NavigationProvider nav, String? lastThreadKey) {
    final parsedLastThread = _threadFromKey(lastThreadKey);
    if (parsedLastThread != null) {
      return parsedLastThread;
    }

    if (nav.selectedGenre != null) {
      final genre = nav.selectedGenre!;
      final subGenre = nav.selectedSubGenre ??
          (genre.subGenres.isNotEmpty ? genre.subGenres.first : null);
      if (subGenre != null) {
        return _ResolvedThread(
          threadKey: Post.buildThreadKey(genreId: genre.id, subGenreId: subGenre.id),
          genre: genre,
          subGenre: subGenre,
        );
      }
    }

    for (final genre in Genre.allGenres) {
      if (genre.subGenres.isNotEmpty) {
        final subGenre = genre.subGenres.first;
        return _ResolvedThread(
          threadKey: Post.buildThreadKey(genreId: genre.id, subGenreId: subGenre.id),
          genre: genre,
          subGenre: subGenre,
        );
      }
    }

    return null;
  }

  _ResolvedThread? _threadFromKey(String? threadKey) {
    if (threadKey == null || threadKey.isEmpty) {
      return null;
    }

    final parts = threadKey.split(':');
    if (parts.length != 2) {
      return null;
    }

    final genre = _genreById(parts[0]);
    if (genre == null) {
      return null;
    }

    final subGenre = genre.subGenres.where((item) => item.id == parts[1]).cast<SubGenre?>().firstWhere(
      (item) => item != null,
      orElse: () => null,
    );
    if (subGenre == null) {
      return null;
    }

    return _ResolvedThread(
      threadKey: threadKey,
      genre: genre,
      subGenre: subGenre,
    );
  }

  Genre? _genreById(String genreId) {
    for (final genre in Genre.allGenres) {
      if (genre.id == genreId) {
        return genre;
      }
    }
    return null;
  }
}

class _ResolvedThread {
  final String threadKey;
  final Genre genre;
  final SubGenre subGenre;

  const _ResolvedThread({
    required this.threadKey,
    required this.genre,
    required this.subGenre,
  });
}
