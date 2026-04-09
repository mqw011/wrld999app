// Place this file in: lib/data/firestore_user_data_source.dart

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user.dart';
import 'local_user_data_source.dart';

class FirestoreUserDataSource implements UserDataSource {
  FirestoreUserDataSource({
    FirebaseFirestore? firestore,
    required String? Function() uidResolver,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _uidResolver = uidResolver;

  final FirebaseFirestore _firestore;
  final String? Function() _uidResolver;

  @override
  Future<User> loadUser() async {
    final uid = _uidResolver();
    if (uid == null || uid.isEmpty) {
      return User.initial();
    }

    final snapshot = await _firestore.collection('users').doc(uid).get();
    if (!snapshot.exists) {
      return User.initial();
    }

    final data = snapshot.data();
    if (data == null) {
      return User.initial();
    }

    return User.fromJson(data);
  }

  @override
  Future<void> saveUser(User user) async {
    final uid = _uidResolver();
    if (uid == null || uid.isEmpty) {
      throw StateError('Cannot save user: auth uid is not available');
    }

    await _firestore.collection('users').doc(uid).set(user.toJson());
  }

  Future<bool> isNewUser(String uid) async {
    final snapshot = await _firestore.collection('users').doc(uid).get();
    return !snapshot.exists;
  }
}
