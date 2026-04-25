import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

/// A class that exposes all the Firebase options used when to configure Firebase.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    // Sur le web, utiliser la configuration web
    if (kIsWeb) {
      return web;
    }

    // Pour les autres plateformes natives
    if (Platform.isAndroid) {
      return android;
    } else if (Platform.isIOS) {
      return ios;
    } else if (Platform.isWindows) {
      return windows;
    } else if (Platform.isMacOS) {
      return macos;
    } else if (Platform.isLinux) {
      return linux;
    }

    // Fallback à Android si plateforme non reconnue
    return android;
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDlFh4nyXfZM8IhyuXAJyHYbxm_khGOAdQ',
    appId: '1:218846846846:web:99ffb202dcfbd204811d2f',
    messagingSenderId: '218846846846',
    projectId: 'markazi-65c39',
    authDomain: 'markazi-65c39.firebaseapp.com',
    storageBucket: 'markazi-65c39.firebasestorage.app',
    measurementId: 'G-H2MR9H6V77',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBNoYewz_7bkUA3yICFUbc5Rgx-Uiy4aR0',
    appId: '1:218846846846:android:c8d146546b8c4a86811d2f',
    messagingSenderId: '218846846846',
    projectId: 'markazi-65c39',
    storageBucket: 'markazi-65c39.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAwOitrIqaiBroCxcGokLVmnN2AU0bwkTo',
    appId: '1:218846846846:ios:9ad26194961b1014811d2f',
    messagingSenderId: '218846846846',
    projectId: 'markazi-65c39',
    storageBucket: 'markazi-65c39.firebasestorage.app',
    iosClientId: '218846846846-i5ogth6l32dcnv1n04pe0ma95835r3d0.apps.googleusercontent.com',
    iosBundleId: 'com.example.markazi',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDlFh4nyXfZM8IhyuXAJyHYbxm_khGOAdQ',
    appId: '1:218846846846:web:54d0a2041a377f16811d2f',
    messagingSenderId: '218846846846',
    projectId: 'markazi-65c39',
    authDomain: 'markazi-65c39.firebaseapp.com',
    storageBucket: 'markazi-65c39.firebasestorage.app',
    measurementId: 'G-0WDZWP7EFM',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAwOitrIqaiBroCxcGokLVmnN2AU0bwkTo',
    appId: '1:218846846846:ios:9ad26194961b1014811d2f',
    messagingSenderId: '218846846846',
    projectId: 'markazi-65c39',
    storageBucket: 'markazi-65c39.firebasestorage.app',
    iosClientId: '218846846846-i5ogth6l32dcnv1n04pe0ma95835r3d0.apps.googleusercontent.com',
    iosBundleId: 'com.example.markazi',
  );

  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'AIzaSyBNoYewz_7bkUA3yICFUbc5Rgx-Uiy4aR0',
    appId: '1:218846846846:linux:abcdef123456lnx',
    messagingSenderId: '218846846846',
    projectId: 'markazi-65c39',
    databaseURL: 'https://markazi-65c39.firebaseio.com',
    storageBucket: 'markazi-65c39.firebasestorage.app',
  );
}