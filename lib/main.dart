import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:talker/talker.dart';

import 'package:talker_riverpod_logger/talker_riverpod_logger_observer.dart';

import 'package:cd_shop/app.dart';
import 'package:cd_shop/firebase_options.dart';
import 'package:cd_shop/injection_container.dart';

final sl = GetIt.instance;

void main() async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      final talker = Talker();

      talker.info('Initializing Firebase...');
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      talker.info('Firebase initialized');

      // Error Handling
      FlutterError.onError = (details) {
        FirebaseCrashlytics.instance.recordFlutterFatalError(details);
        talker.handle(
          details.exception,
          details.stack,
          'Uncaught Flutter Error',
        );
      };

      WidgetsBinding.instance.platformDispatcher.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        talker.handle(error, stack, 'Uncaught Platform Error');
        return true;
      };

      // Firestore settings
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
      );
      talker.info('Firestore offline persistence enabled');

      // Initialize dependencies (GetIt + Injectable)
      talker.info('Initializing dependencies...');
      await initDependencies();
      talker.info('Dependencies initialized');

      talker.info('Launching app');
      runApp(
        ProviderScope(
          observers: [TalkerRiverpodObserver(talker: talker)],
          child: const App(),
        ),
      );
    },
    (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      // Try to get talker if initialized, otherwise print
      if (GetIt.instance.isRegistered<Talker>()) {
        sl<Talker>().handle(error, stack, 'Uncaught Zone Error');
      } else {
        debugPrint('Uncaught Zone Error: $error\n$stack');
      }
    },
  );
}
