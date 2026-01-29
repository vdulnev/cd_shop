// Run with: flutter test integration_test/seed_firestore_test.dart
//
// Make sure to:
// 1. Run `flutterfire configure` first
// 2. Have a device/emulator connected

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:cd_shop/firebase_options.dart';
import 'package:cd_shop/core/services/firestore_seeder.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Seed Firestore with products', (tester) async {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    final seeder = FirestoreSeeder();

    // Seed products
    final count = await seeder.seedProducts();
    debugPrint('Seeded $count products');

    // Verify
    final snapshot =
        await FirebaseFirestore.instance.collection('products').get();
    debugPrint('Total products in Firestore: ${snapshot.docs.length}');

    expect(snapshot.docs.length, greaterThan(0));
  });
}
