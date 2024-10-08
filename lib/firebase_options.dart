// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
        return macos;
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
    apiKey: 'AIzaSyDkuK4Xsa3SxDkeKahnK0XG-jN2QuIsd2o',
    appId: '1:558902312458:web:aefe1e7c2f6e62f32529f3',
    messagingSenderId: '558902312458',
    projectId: 'busesproject',
    authDomain: 'busesproject.firebaseapp.com',
    storageBucket: 'busesproject.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDzlK4_XYSdMCVaTysBbprWVDFtxY8Tw0A',
    appId: '1:558902312458:android:1eabb333258d9c932529f3',
    messagingSenderId: '558902312458',
    projectId: 'busesproject',
    storageBucket: 'busesproject.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC0rLJluDm7-i3RiGG_xQj-H1nJHVaPrJ0',
    appId: '1:558902312458:ios:9c5ac8472551fa0e2529f3',
    messagingSenderId: '558902312458',
    projectId: 'busesproject',
    storageBucket: 'busesproject.appspot.com',
    iosClientId: '558902312458-vv85an5f5k9gshsqke31svb9ssf60ebm.apps.googleusercontent.com',
    iosBundleId: 'com.example.meVoyUsuario',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyC0rLJluDm7-i3RiGG_xQj-H1nJHVaPrJ0',
    appId: '1:558902312458:ios:9c5ac8472551fa0e2529f3',
    messagingSenderId: '558902312458',
    projectId: 'busesproject',
    storageBucket: 'busesproject.appspot.com',
    iosClientId: '558902312458-vv85an5f5k9gshsqke31svb9ssf60ebm.apps.googleusercontent.com',
    iosBundleId: 'com.example.meVoyUsuario',
  );
}
