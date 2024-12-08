// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyD9H9yGJqwVV3ZUhB1DMQXwfaS3HWEdsTg',
    appId: '1:650479950400:web:0760600a9f013af5ec9da5',
    messagingSenderId: '650479950400',
    projectId: 'farm-direct-1b463',
    authDomain: 'farm-direct-1b463.firebaseapp.com',
    storageBucket: 'farm-direct-1b463.firebasestorage.app',
    measurementId: 'G-1WH04Y4HYH',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCTFJWuUSF-ht6eoLj0kPPmZlmU3kBpjao',
    appId: '1:650479950400:android:b2ee3e672bbdb998ec9da5',
    messagingSenderId: '650479950400',
    projectId: 'farm-direct-1b463',
    storageBucket: 'farm-direct-1b463.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBTNw1LHQVrtb3VW4PMy3Fpw3ovBX5GdEo',
    appId: '1:650479950400:ios:1f0962eb449bdc52ec9da5',
    messagingSenderId: '650479950400',
    projectId: 'farm-direct-1b463',
    storageBucket: 'farm-direct-1b463.firebasestorage.app',
    iosBundleId: 'com.farmdirect.farmstore',
  );
}
