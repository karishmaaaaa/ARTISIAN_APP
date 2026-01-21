import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return FirebaseOptions(
        apiKey: "AIzaSyBwLGONwpld7adi5845Hp6PWr77TFIiybk",
        authDomain: "artisian-fb28a.firebaseapp.com",
        projectId: "artisian-fb28a",
        storageBucket: "artisian-fb28a.firebasestorage.app",
        messagingSenderId: "489829627224",
        appId: "1:489829627224:web:0f82cabbf828af2793a12d",
        measurementId: "G-52KJ7VGC7T",
      );
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return FirebaseOptions(
          apiKey: "AIzaSyBwLGONwpld7adi5845Hp6PWr77TFIiybk",
          appId: "1:489829627224:web:0f82cabbf828af2793a12d",
          messagingSenderId: "489829627224",
          projectId: "artisian-fb28a",
          storageBucket: "artisian-fb28a.firebasestorage.app",
        );
      case TargetPlatform.iOS:
        return FirebaseOptions(
          apiKey: "AIzaSyBwLGONwpld7adi5845Hp6PWr77TFIiybk",
          appId: "1:489829627224:web:0f82cabbf828af2793a12d",
          messagingSenderId: "489829627224",
          projectId: "artisian-fb28a",
          storageBucket: "artisian-fb28a.appspot.com",
          iosBundleId: "com.example.artisianapp",
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }
}