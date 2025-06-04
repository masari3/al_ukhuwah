import 'dart:ui';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:al_ukhuwah/app.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'di/providers.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initFirebase();
  Intl.defaultLocale = 'id_ID';

  final currentTheme = await AdaptiveTheme.getThemeMode();
  runApp(
    UncontrolledProviderScope(
      container: await _bootstrap(),
      child: MyApp(
        adaptiveThemeMode: currentTheme,
      ),
    ),
  );
}

Future<void> _initFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
}

Future<ProviderContainer> _bootstrap() async {
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
    ],
  );
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.muslimdeveloper.edusystem.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );
  return container;
}
