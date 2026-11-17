// Android options derived from android/app/google-services.json.
// Use FlutterFire CLI to register and configure additional platforms.
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return android;
    }
    throw UnsupportedError(
      'Firebase is configured for Android only. Register this platform in '
      'Firebase and run flutterfire configure to add iOS or web support.',
    );
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyAvCzUF1UWiW3V_GXbIhm1ArqfFirFWCyE",
    appId: "1:260556728621:android:782d5a005dbce5983c0ba4",
    messagingSenderId: "260556728621",
    projectId: "sampts-ea8c4",
    databaseURL: "https://sampts-ea8c4-default-rtdb.firebaseio.com",
    storageBucket: "sampts-ea8c4.firebasestorage.app",
  );
}
