// Place this file in: lib/providers/user_provider.dart

import 'package:flutter/material.dart';

import '../data/local_user_data_source.dart';
import '../models/user.dart';

class UserProvider extends ChangeNotifier {
  UserProvider({UserDataSource? dataSource})
    : _dataSource = dataSource ?? LocalUserDataSource() {
    _initialLoad = _loadUser();
  }

  final UserDataSource _dataSource;
  late final Future<void> _initialLoad;
  User _user = User.initial();
  bool _isLoaded = false;

  User get user => _user;
  bool get isLoaded => _isLoaded;

  Future<void> waitUntilLoaded() => _initialLoad;

  Future<void> updateProfile({
    required String username,
    required String bio,
    List<String>? favoriteGenreIds,
  }) async {
    await waitUntilLoaded();

    _user = _user.copyWith(
      username: username.trim().isEmpty ? _user.username : username.trim(),
      bio: bio.trim(),
      favoriteGenreIds: favoriteGenreIds ?? _user.favoriteGenreIds,
    );
    notifyListeners();
    await _dataSource.saveUser(_user);
  }

  Future<void> setFavoriteGenres(List<String> favoriteGenreIds) async {
    await waitUntilLoaded();

    _user = _user.copyWith(
      favoriteGenreIds: List<String>.unmodifiable(favoriteGenreIds),
    );
    notifyListeners();
    await _dataSource.saveUser(_user);
  }

  Future<void> setLastThread(String? threadKey) async {
    await waitUntilLoaded();

    _user = _user.copyWith(lastThreadKey: threadKey);
    notifyListeners();
    await _dataSource.saveUser(_user);
  }

  Future<void> resetOnboarding() async {
    await waitUntilLoaded();

    _user = User.initial().copyWith(lastThreadKey: _user.lastThreadKey);
    notifyListeners();
    await _dataSource.saveUser(_user);
  }

  Future<void> _loadUser() async {
    _user = await _dataSource.loadUser();
    _isLoaded = true;
    notifyListeners();
  }
}
