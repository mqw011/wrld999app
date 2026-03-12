import 'package:flutter/material.dart';
import '../models/genre.dart';

/// Manages hierarchical navigation with a simple stack:
/// Explore → Genre → Sub-genre → Discussion
enum AppScreen { onboarding, explore, genre, subGenre, discussion }

class NavigationProvider extends ChangeNotifier {
  List<Map<String, Object?>> _stack = [_route(screen: AppScreen.onboarding)];
  bool _onboardingComplete = false;

  static Map<String, Object?> _route({
    required AppScreen screen,
    Genre? genre,
    SubGenre? subGenre,
  }) {
    return {'screen': screen, 'genre': genre, 'subGenre': subGenre};
  }

  Map<String, Object?> get _currentEntry => _stack.last;
  AppScreen get _rootScreen =>
      _onboardingComplete ? AppScreen.explore : AppScreen.onboarding;

  // ── Getters ──────────────────────────────────────────────
  AppScreen get currentScreen => _currentEntry['screen'] as AppScreen;
  Genre? get selectedGenre => _currentEntry['genre'] as Genre?;
  SubGenre? get selectedSubGenre => _currentEntry['subGenre'] as SubGenre?;
  bool get onboardingComplete => _onboardingComplete;
  List<AppScreen> get stack =>
      List.unmodifiable(_stack.map((entry) => entry['screen'] as AppScreen));

  // ── Navigation actions ───────────────────────────────────
  void completeOnboarding() {
    _onboardingComplete = true;
    _stack = [_route(screen: AppScreen.explore)];
    notifyListeners();
  }

  void navigateToExplore() {
    _stack = [_route(screen: _rootScreen)];
    notifyListeners();
  }

  void navigateToGenre(Genre genre) {
    _stack = [
      _route(screen: _rootScreen),
      _route(screen: AppScreen.genre, genre: genre),
    ];
    notifyListeners();
  }

  void navigateToSubGenre(SubGenre subGenre) {
    final genre = selectedGenre;
    if (genre == null) {
      return;
    }

    _stack = [
      ..._stack,
      _route(screen: AppScreen.subGenre, genre: genre, subGenre: subGenre),
    ];
    notifyListeners();
  }

  void navigateToDiscussion() {
    final genre = selectedGenre;
    if (genre == null || currentScreen == AppScreen.discussion) {
      return;
    }

    _stack = [
      ..._stack,
      _route(
        screen: AppScreen.discussion,
        genre: genre,
        subGenre: selectedSubGenre,
      ),
    ];
    notifyListeners();
  }

  void goBack() {
    if (!canGoBack) {
      return;
    }

    _stack = _stack.sublist(0, _stack.length - 1);
    notifyListeners();
  }

  void popToScreen(AppScreen screen) {
    if (!_stack.any((entry) => entry['screen'] == screen)) {
      return;
    }

    while (_stack.length > 1 && currentScreen != screen) {
      _stack = _stack.sublist(0, _stack.length - 1);
    }

    notifyListeners();
  }

  /// Whether a back action is available.
  bool get canGoBack => _stack.length > 1;
}
