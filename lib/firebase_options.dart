import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Firebase apps registered in project live-score-app-anupom.
/// These client identifiers are public configuration, not credentials.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => android,
      _ => throw UnsupportedError(
        'Firebase is configured for Android and Web only. See README.md.',
      ),
    };
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCi0_8eDV199hS1xkS2K97DePlvtLZITTo',
    appId: '1:248981517428:web:f659e639819d6f03934d21',
    messagingSenderId: '248981517428',
    projectId: 'live-score-app-anupom',
    authDomain: 'live-score-app-anupom.firebaseapp.com',
    storageBucket: 'live-score-app-anupom.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDHSnau2rgkv4QzV5im_JM-cmMcEZA_Pkk',
    appId: '1:248981517428:android:4bc634451f0974ca934d21',
    messagingSenderId: '248981517428',
    projectId: 'live-score-app-anupom',
    storageBucket: 'live-score-app-anupom.firebasestorage.app',
  );
}
