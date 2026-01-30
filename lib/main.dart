import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:talker/talker.dart';

import 'package:cd_shop/app.dart';
import 'package:cd_shop/firebase_options.dart';
import 'package:cd_shop/injection_container.dart';
import 'package:talker_riverpod_logger/talker_riverpod_logger_observer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize Firebase
  final talker = Talker();
  talker.info('Initializing Firebase...');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  talker.info('Firebase initialized');

  // 2. Set up Crashlytics error handling
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  talker.info('Crashlytics error handling configured');

  // 3. Enable Firestore offline persistence
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );
  talker.info('Firestore offline persistence enabled');

  // 4. Initialize dependencies
  await initDependencies();

  talker.info('Launching app');
  runApp(
    ProviderScope(observers: [TalkerRiverpodObserver()], child: const App()),
  );
}
