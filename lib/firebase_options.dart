// File generated from google-services.json
// DO NOT EDIT — regenerate with: flutterfire configure

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web. '
        'Reconfigure with: flutterfire configure',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for iOS. '
          'Reconfigure with: flutterfire configure',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBm3whDiSG-2iVfrwf1MksHsjZACsVDoNg',
    appId: '1:761509708838:android:cf2a7c4a2a61a14f6c92e7',
    messagingSenderId: '761509708838',
    projectId: 'fin-track-2604',
    storageBucket: 'fin-track-2604.firebasestorage.app',
  );
}
