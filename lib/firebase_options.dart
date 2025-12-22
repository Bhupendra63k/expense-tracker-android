import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.windows:
        return windows;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAmQbFV6fulT2kj-mrX387-GBnRw9GxLzs',
    appId: '1:819404896244:web:bf15e65f8bb8aa46b22ba1',
    messagingSenderId: '819404896244',
    projectId: 'expense-tracker-pro-575b7',
    authDomain: 'expense-tracker-pro-575b7.firebaseapp.com',
    storageBucket: 'expense-tracker-pro-575b7.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDummy-Replace-This-Key',
    appId: '1:819404896244:android:bf15e65f8bb8aa46b22ba1',
    messagingSenderId: '819404896244',
    projectId: 'expense-tracker-pro-575b7',
    storageBucket: 'expense-tracker-pro-575b7.firebasestorage.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDummy-Replace-This-Key',
    appId: '1:819404896244:android:bf15e65f8bb8aa46b22ba1',
    messagingSenderId: '819404896244',
    projectId: 'expense-tracker-pro-575b7',
    authDomain: 'expense-tracker-pro-575b7.firebaseapp.com',
    storageBucket: 'expense-tracker-pro-575b7.firebasestorage.app',
  );
}