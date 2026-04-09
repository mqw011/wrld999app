// Place this file in: lib/providers/user_provider.dart

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';

import '../data/firestore_user_data_source.dart';
import '../data/local_user_data_source.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class UserProvider extends ChangeNotifier {
  UserProvider({UserDataSource? dataSource, AuthService? authService})
    : _localDataSource = dataSource ?? LocalUserDataSource(),
      _authService = authService ?? AuthService() {
    _dataSource = _localDataSource;
    _initialLoad = _loadUser();
    _authSubscription = _authService.authStateChanges.listen(
      _handleAuthStateChanged,
    );
  }

  final UserDataSource _localDataSource;
  final AuthService _authService;
  late UserDataSource _dataSource;
  late final Future<void> _initialLoad;
  StreamSubscription<firebase_auth.User?>? _authSubscription;
  User _user = User.initial();
  bool _isLoaded = false;
  String? _uid;

  User get user => _user;
  bool get isLoaded => _isLoaded;
  String? get uid => _uid;

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

  Future<void> _handleAuthStateChanged(firebase_auth.User? authUser) async {
    if (authUser == null) {
      _uid = null;
      _dataSource = _localDataSource;
      _user = User.initial();
      _isLoaded = true;
      notifyListeners();
      return;
    }

    _uid = authUser.uid;
    _isLoaded = false;
    _dataSource = FirestoreUserDataSource(uidResolver: () => _uid);
    notifyListeners();
    await _loadUser();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
