import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDbHWtvobBlvn_fKmCC4x9u1ollr1hdFtM',
    appId: '1:613529712540:web:placeholder',
    messagingSenderId: '613529712540',
    projectId: 'umrahease-6576b',
    authDomain: 'umrahease-6576b.firebaseapp.com',
    storageBucket: 'umrahease-6576b.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDbHWtvobBlvn_fKmCC4x9u1ollr1hdFtM',
    appId: '1:613529712540:android:a5759e63830598c0aeba59',
    messagingSenderId: '613529712540',
    projectId: 'umrahease-6576b',
    storageBucket: 'umrahease-6576b.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDbHWtvobBlvn_fKmCC4x9u1ollr1hdFtM',
    appId: '1:613529712540:ios:placeholder',
    messagingSenderId: '613529712540',
    projectId: 'umrahease-6576b',
    storageBucket: 'umrahease-6576b.firebasestorage.app',
    iosBundleId: 'com.umrahease.com',
  );
}
