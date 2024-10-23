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
        return macos;
      case TargetPlatform.windows:
        return windows;
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
    apiKey: 'AIzaSyDndTtHLkvRd5Oojq0p4g3YCVBZwqTPJiA',
    appId: '1:17317623844:web:4405c5d6c808f45e2400b1',
    messagingSenderId: '17317623844',
    projectId: 'matchday-54d8f',
    authDomain: 'matchday-54d8f.firebaseapp.com',
    storageBucket: 'matchday-54d8f.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDSRjjEUlQNL16oFxvMDU9z6D62YcaNg-c',
    appId: '1:17317623844:android:1bed4c616162e78f2400b1',
    messagingSenderId: '17317623844',
    projectId: 'matchday-54d8f',
    storageBucket: 'matchday-54d8f.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAf676Hvvo_tV5jpHohIhilq7aRyRAXK7M',
    appId: '1:17317623844:ios:28f5b1afe5db92f72400b1',
    messagingSenderId: '17317623844',
    projectId: 'matchday-54d8f',
    storageBucket: 'matchday-54d8f.appspot.com',
    iosBundleId: 'com.example.matchDay',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAf676Hvvo_tV5jpHohIhilq7aRyRAXK7M',
    appId: '1:17317623844:ios:28f5b1afe5db92f72400b1',
    messagingSenderId: '17317623844',
    projectId: 'matchday-54d8f',
    storageBucket: 'matchday-54d8f.appspot.com',
    iosBundleId: 'com.example.matchDay',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDndTtHLkvRd5Oojq0p4g3YCVBZwqTPJiA',
    appId: '1:17317623844:web:f2c5b853458cfb872400b1',
    messagingSenderId: '17317623844',
    projectId: 'matchday-54d8f',
    authDomain: 'matchday-54d8f.firebaseapp.com',
    storageBucket: 'matchday-54d8f.appspot.com',
  );
}