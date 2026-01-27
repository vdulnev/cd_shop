import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import 'package:cd_shop/app.dart';
import 'package:cd_shop/injection_container.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await initDependencies();
  });

  tearDown(() async {
    await GetIt.instance.reset();
  });

  testWidgets('App builds without errors', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: App()));

    // Flush pending timers from async DB operations (Floor/sqflite)
    await tester.pump(const Duration(seconds: 10));

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
