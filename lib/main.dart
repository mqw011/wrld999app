import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'providers/post_provider.dart';
import 'providers/theme_manager.dart';
import 'providers/navigation_provider.dart';
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
    final tm = context.read<ThemeManager>();

    return PopScope(
      canPop: !nav.canGoBack,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) nav.goBack();
      },
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
        child: _buildScreen(nav, tm),
      ),
    );
  }

  Widget _buildScreen(NavigationProvider nav, ThemeManager tm) {
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
        if (nav.selectedGenre != null) {
          return DiscussionThreadScreen(
            key: ValueKey(
              'discussion-${nav.selectedGenre!.id}-${nav.selectedSubGenre?.id ?? 'root'}',
            ),
            genre: nav.selectedGenre!,
            subGenre: nav.selectedSubGenre,
          );
        }
        return const ExploreHubScreen(key: ValueKey('explore-fallback3'));
    }
  }
}
