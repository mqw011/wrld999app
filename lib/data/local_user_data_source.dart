// Place this file in: lib/data/local_user_data_source.dart

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';

abstract class UserDataSource {
  Future<User> loadUser();

  Future<void> saveUser(User user);
}

class LocalUserDataSource implements UserDataSource {
  static const String _storageKey = 'wrld.user.profile.v1';

  @override
  Future<User> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final rawJson = prefs.getString(_storageKey);

    if (rawJson == null || rawJson.isEmpty) {
      return User.initial();
    }

    try {
      final decoded = jsonDecode(rawJson);
      if (decoded is! Map<String, dynamic>) {
        return User.initial();
      }

      return User.fromJson(decoded);
    } catch (_) {
      return User.initial();
    }
  }

  @override
  Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(user.toJson()));
  }
}
