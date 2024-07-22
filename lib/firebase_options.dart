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
    apiKey: 'AIzaSyBEQou1v6idfPOy-KBi4Yi8qkcB1fSTEbA',
    appId: '1:145980932421:web:497492c484873b18d63e2c',
    messagingSenderId: '145980932421',
    projectId: 'imagecontent-ebd70',
    authDomain: 'imagecontent-ebd70.firebaseapp.com',
    databaseURL: 'https://imagecontent-ebd70-default-rtdb.firebaseio.com',
    storageBucket: 'imagecontent-ebd70.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBEnulwNr4ibByX_ldY7qGFRu54a4Oznsg',
    appId: '1:145980932421:android:83309fda4bd20197d63e2c',
    messagingSenderId: '145980932421',
    projectId: 'imagecontent-ebd70',
    databaseURL: 'https://imagecontent-ebd70-default-rtdb.firebaseio.com',
    storageBucket: 'imagecontent-ebd70.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDFBwTJss7Z-Y3QGQnX9RRFgexA8mshA68',
    appId: '1:145980932421:ios:0b0dd101a345f013d63e2c',
    messagingSenderId: '145980932421',
    projectId: 'imagecontent-ebd70',
    databaseURL: 'https://imagecontent-ebd70-default-rtdb.firebaseio.com',
    storageBucket: 'imagecontent-ebd70.appspot.com',
    androidClientId: '145980932421-4j0m6ppcmatob5vf2adpnbqbdpf5i1ji.apps.googleusercontent.com',
    iosClientId: '145980932421-6v83bnc0i954lbo092i4vdunojnvds6p.apps.googleusercontent.com',
    iosBundleId: 'com.example.imagecontent',
  );
}