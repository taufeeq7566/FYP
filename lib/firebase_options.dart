// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA7PIjHKC2eTGc9NiB4yjZorrC7szYiEJ4',
    appId: '1:859383331914:web:aa0e062d9d5397513e3ab3',
    messagingSenderId: '859383331914',
    projectId: 'marathon-35ffa',
    authDomain: 'marathon-35ffa.firebaseapp.com',
    storageBucket: 'marathon-35ffa.appspot.com',
    measurementId: 'G-8NM1PTT3N2',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDwR4pRq2UZjTeYLsl7EJtbKCbGCCp2pkg',
    appId: '1:859383331914:android:74b3ba23e7aeac1a3e3ab3',
    messagingSenderId: '859383331914',
    projectId: 'marathon-35ffa',
    storageBucket: 'marathon-35ffa.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC4MC3X9xyGr92vmBPHWeWJCCgP8aylllI',
    appId: '1:859383331914:ios:f06659698e49d8e23e3ab3',
    messagingSenderId: '859383331914',
    projectId: 'marathon-35ffa',
    storageBucket: 'marathon-35ffa.appspot.com',
    iosClientId: '859383331914-479239fvfp8hgmrshj424ufkmdhpc4bs.apps.googleusercontent.com',
    iosBundleId: 'com.example.checkpointGeofence',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyC4MC3X9xyGr92vmBPHWeWJCCgP8aylllI',
    appId: '1:859383331914:ios:f06659698e49d8e23e3ab3',
    messagingSenderId: '859383331914',
    projectId: 'marathon-35ffa',
    storageBucket: 'marathon-35ffa.appspot.com',
    iosClientId: '859383331914-479239fvfp8hgmrshj424ufkmdhpc4bs.apps.googleusercontent.com',
    iosBundleId: 'com.example.checkpointGeofence',
  );
}
