// IMPORTANT: Replace all placeholder values below with your actual Firebase
// project values. You can get them from:
// 1. Firebase Console → Project Settings → Your apps → SDK setup
// 2. Or run: flutterfire configure  (installs: dart pub global activate flutterfire_cli)
//
// For Android: also place google-services.json in android/app/
// For iOS: place GoogleService-Info.plist in ios/Runner/
//
// Required Firebase Console setup:
// 1. Create a Firebase project at console.firebase.google.com
// 2. Register Android app with package name: com.shadow.wrld999
// 3. Enable Authentication → Sign-in method → Google
// 4. Download google-services.json → place in android/app/

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  DefaultFirebaseOptions._();
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux — '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCpwhfUrd8_bnbl5OrHz7VQAxuze9kMn3U',
    appId: '1:769519837803:android:605563afce4e822e1f072e',
    messagingSenderId: '769519837803',
    projectId: 'wrld999-6b36e',
    storageBucket: 'wrld999-6b36e.firebasestorage.app',
  );

  // Replace with values from Firebase Console → Project Settings → General

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDB0boZGv1IxrH_pgIOigAxywu_IDXK61w',
    appId: '1:769519837803:ios:b6e14b5069bbc7c61f072e',
    messagingSenderId: '769519837803',
    projectId: 'wrld999-6b36e',
    storageBucket: 'wrld999-6b36e.firebasestorage.app',
    iosClientId: '769519837803-hqcdsi10l8qvbtk7no5k77sspggo9tp3.apps.googleusercontent.com',
    iosBundleId: 'com.shadow.wrld9991.15.8.ios',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDB0boZGv1IxrH_pgIOigAxywu_IDXK61w',
    appId: '1:769519837803:ios:4c8f7343525d758a1f072e',
    messagingSenderId: '769519837803',
    projectId: 'wrld999-6b36e',
    storageBucket: 'wrld999-6b36e.firebasestorage.app',
    iosClientId: '769519837803-i6sbcejpr203u39kng56auahvujli61d.apps.googleusercontent.com',
    iosBundleId: 'com.shadow.wrld999',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAmVrfbVq6CW8nUSPYsAiRlSnmVwPb4FcU',
    appId: '1:769519837803:web:eda8920d7ad5829c1f072e',
    messagingSenderId: '769519837803',
    projectId: 'wrld999-6b36e',
    authDomain: 'wrld999-6b36e.firebaseapp.com',
    storageBucket: 'wrld999-6b36e.firebasestorage.app',
    measurementId: 'G-CRZSKZ5BZX',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'YOUR_WEB_API_KEY',
    appId: '1:YOUR_PROJECT_NUMBER:web:YOUR_APP_ID_HASH',
    messagingSenderId: 'YOUR_PROJECT_NUMBER',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_PROJECT_ID.appspot.com',
    authDomain: 'YOUR_PROJECT_ID.firebaseapp.com',
  );
}