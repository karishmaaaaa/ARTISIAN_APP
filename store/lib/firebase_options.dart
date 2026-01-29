import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Firebase configuration options for different platforms.
/// 
/// IMPORTANT: Replace these placeholder values with your actual Firebase
/// project configuration from the Firebase Console.
/// 
/// To get these values:
/// 1. Go to Firebase Console (https://console.firebase.google.com)
/// 2. Select your project
/// 3. Click the gear icon → Project settings
/// 4. Scroll down to "Your apps" and select your platform
/// 5. Copy the configuration values
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
    apiKey: 'AIzaSyCyHAB2VBb8VLYMMIjNWr9IGHM8aaxP31c',
    appId: '1:1021027683024:web:34227a1a002760f9bc2cd5',
    messagingSenderId: '1021027683024',
    projectId: 'artisan-swi',
    authDomain: 'artisan-swi.firebaseapp.com',
    storageBucket: 'artisan-swi.firebasestorage.app',
  );

  // TODO: Replace with your actual Firebase Web configuration

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAyyQp7m_EHisIS5BTnmysQajgac2YS--E',
    appId: '1:1021027683024:android:3468ee33b0122a6ebc2cd5',
    messagingSenderId: '1021027683024',
    projectId: 'artisan-swi',
    storageBucket: 'artisan-swi.firebasestorage.app',
  );

  // TODO: Replace with your actual Firebase Android configuration

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDqDRVuclODWyFQI49u06x3tqPGWKms5Xg',
    appId: '1:1021027683024:ios:fe22a48d4a3e73afbc2cd5',
    messagingSenderId: '1021027683024',
    projectId: 'artisan-swi',
    storageBucket: 'artisan-swi.firebasestorage.app',
    iosBundleId: 'com.example.artisanMarketplace',
  );

  // TODO: Replace with your actual Firebase iOS configuration

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDqDRVuclODWyFQI49u06x3tqPGWKms5Xg',
    appId: '1:1021027683024:ios:fe22a48d4a3e73afbc2cd5',
    messagingSenderId: '1021027683024',
    projectId: 'artisan-swi',
    storageBucket: 'artisan-swi.firebasestorage.app',
    iosBundleId: 'com.example.artisanMarketplace',
  );

  // TODO: Replace with your actual Firebase macOS configuration

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCyHAB2VBb8VLYMMIjNWr9IGHM8aaxP31c',
    appId: '1:1021027683024:web:3ab10818670a6fffbc2cd5',
    messagingSenderId: '1021027683024',
    projectId: 'artisan-swi',
    authDomain: 'artisan-swi.firebaseapp.com',
    storageBucket: 'artisan-swi.firebasestorage.app',
  );
