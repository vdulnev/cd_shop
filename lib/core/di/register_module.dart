import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
import 'package:talker/talker.dart';

@module
abstract class RegisterModule {
  @singleton
  Talker get talker => Talker();

  @lazySingleton
  FirebaseAuth get firebaseAuth => FirebaseAuth.instance;

  @lazySingleton
  FirebaseFirestore get firestore => FirebaseFirestore.instance;

  @singleton
  FirebaseAnalytics get firebaseAnalytics => FirebaseAnalytics.instance;
}
