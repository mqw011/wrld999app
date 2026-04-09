// Place this file in: lib/services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  AuthService({
    firebase_auth.FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  }) : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
       _googleSignIn =
           googleSignIn ?? GoogleSignIn(scopes: const <String>['email']);

  final firebase_auth.FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  Stream<firebase_auth.User?> get authStateChanges =>
      _firebaseAuth.authStateChanges();

  Future<firebase_auth.UserCredential> signInWithGoogle() async {
    if (kIsWeb) {
      final provider = firebase_auth.GoogleAuthProvider();
      return _firebaseAuth.signInWithPopup(provider);
    }

    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw const AuthCancelledException();
    }

    final googleAuth = await googleUser.authentication;
    final credential = firebase_auth.GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return _firebaseAuth.signInWithCredential(credential);
  }

  Future<void> signOut() async {
    await Future.wait<void>([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }
}

class AuthCancelledException implements Exception {
  const AuthCancelledException();

  @override
  String toString() {
    return 'Google sign-in was cancelled by user';
  }
}
