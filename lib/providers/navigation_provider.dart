import 'package:flutter/material.dart';
import '../models/genre.dart';

/// Manages the hierarchical navigation state:
/// Explore → Genre → Sub-genre → Discussion
enum AppScreen { onboarding, explore, genre, subGenre, discussion }

class NavigationProvider extends ChangeNotifier {
  AppScreen _currentScreen = AppScreen.onboarding;
  Genre? _selectedGenre;
  SubGenre? _selectedSubGenre;
  bool _onboardingComplete = false;

  // ── Getters ──────────────────────────────────────────────
  AppScreen get currentScreen => _currentScreen;
  Genre? get selectedGenre => _selectedGenre;
  SubGenre? get selectedSubGenre => _selectedSubGenre;
  bool get onboardingComplete => _onboardingComplete;

  // ── Navigation actions ───────────────────────────────────
  void completeOnboarding() {
    _onboardingComplete = true;
    _currentScreen = AppScreen.explore;
    notifyListeners();
  }

  void navigateToExplore() {
    _currentScreen = AppScreen.explore;
    _selectedGenre = null;
    _selectedSubGenre = null;
    notifyListeners();
  }

  void navigateToGenre(Genre genre) {
    _currentScreen = AppScreen.genre;
    _selectedGenre = genre;
    _selectedSubGenre = null;
    notifyListeners();
  }

  void navigateToSubGenre(SubGenre subGenre) {
    _currentScreen = AppScreen.subGenre;
    _selectedSubGenre = subGenre;
    notifyListeners();
  }

  void navigateToDiscussion() {
    _currentScreen = AppScreen.discussion;
    notifyListeners();
  }

  void goBack() {
    switch (_currentScreen) {
      case AppScreen.discussion:
        _currentScreen = AppScreen.subGenre;
        break;
      case AppScreen.subGenre:
        _currentScreen = AppScreen.genre;
        _selectedSubGenre = null;
        break;
      case AppScreen.genre:
        _currentScreen = AppScreen.explore;
        _selectedGenre = null;
        break;
      case AppScreen.explore:
      case AppScreen.onboarding:
        break;
    }
    notifyListeners();
  }

  /// Whether a back action is available.
  bool get canGoBack =>
      _currentScreen != AppScreen.explore &&
      _currentScreen != AppScreen.onboarding;
}
