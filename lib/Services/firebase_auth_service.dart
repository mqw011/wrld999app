import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';

class FirebaseAuthService {
  FirebaseAuthService._();

  static final _auth = FirebaseAuth.instance;
  static final _googleSignIn = GoogleSignIn();

  static User? get currentUser => _auth.currentUser;

  static Future<User?> signInWithGoogle() async {
    final GoogleSignInAccount? googleAccount = await _googleSignIn.signIn();
    if (googleAccount == null) return null; // user cancelled

    final GoogleSignInAuthentication googleAuth =
        await googleAccount.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final UserCredential userCredential =
        await _auth.signInWithCredential(credential);
    final User? user = userCredential.user;

    if (user != null) {
      await _saveUserToHive(user);
    }
    return user;
  }

  static Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    await _clearUserFromHive();
  }

  static Future<void> _saveUserToHive(User user) async {
    final box = Hive.box('settings');
    await box.put('userId', user.uid);
    await box.put('name', user.displayName ?? 'User');
    await box.put('userEmail', user.email ?? '');
    await box.put('userPhotoUrl', user.photoURL ?? '');
    await box.put('isGoogleSignIn', true);
  }

  static Future<void> _clearUserFromHive() async {
    final box = Hive.box('settings');
    await box.delete('userId');
    await box.delete('name');
    await box.delete('userEmail');
    await box.delete('userPhotoUrl');
    await box.put('isGoogleSignIn', false);
  }
}
