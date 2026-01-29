// GENERATED FILE - DO NOT EDIT MANUALLY
// This file will be overwritten by FlutterFire CLI.
//
// To regenerate, run:
//   flutterfire configure --project=<your-firebase-project-id>
//
// For setup instructions, see:
//   https://firebase.google.com/docs/flutter/setup

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Run `flutterfire configure` to generate the actual configuration
/// for your Firebase project.
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

  // TODO: Replace these placeholder values by running:
  //   flutterfire configure --project=<your-firebase-project-id>

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBCXtQfnZCJfZs1Gp7mlKTqTFmYYDHRvG8',
    appId: '1:131116124632:web:f7bc361b1655d10af20aad',
    messagingSenderId: '131116124632',
    projectId: 'cd-shop-5d4ec',
    authDomain: 'cd-shop-5d4ec.firebaseapp.com',
    storageBucket: 'cd-shop-5d4ec.firebasestorage.app',
    measurementId: 'G-NHM90Z6X93',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAhK-eTc-6xxEPay4ruv52Zai8JQGYo6r4',
    appId: '1:131116124632:android:0241804169994fd1f20aad',
    messagingSenderId: '131116124632',
    projectId: 'cd-shop-5d4ec',
    storageBucket: 'cd-shop-5d4ec.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCdRRjQOwtPzpxyNZ9JsQDf-BJ12OxBFEQ',
    appId: '1:131116124632:ios:1a8499aaf68a3524f20aad',
    messagingSenderId: '131116124632',
    projectId: 'cd-shop-5d4ec',
    storageBucket: 'cd-shop-5d4ec.firebasestorage.app',
    iosBundleId: 'com.example.cdShop',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCdRRjQOwtPzpxyNZ9JsQDf-BJ12OxBFEQ',
    appId: '1:131116124632:ios:1a8499aaf68a3524f20aad',
    messagingSenderId: '131116124632',
    projectId: 'cd-shop-5d4ec',
    storageBucket: 'cd-shop-5d4ec.firebasestorage.app',
    iosBundleId: 'com.example.cdShop',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBCXtQfnZCJfZs1Gp7mlKTqTFmYYDHRvG8',
    appId: '1:131116124632:web:3a2b5b2c0f378762f20aad',
    messagingSenderId: '131116124632',
    projectId: 'cd-shop-5d4ec',
    authDomain: 'cd-shop-5d4ec.firebaseapp.com',
    storageBucket: 'cd-shop-5d4ec.firebasestorage.app',
    measurementId: 'G-FR3KQCK07T',
  );

}