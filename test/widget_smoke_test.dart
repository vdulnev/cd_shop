import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cd_shop/app.dart';
import 'package:cd_shop/injection_container.dart';

void main() {
  testWidgets('App builds without errors', (WidgetTester tester) async {
    // Ensure bindings and initialize DI for widgets relying on GetIt
    TestWidgetsFlutterBinding.ensureInitialized();
    await initDependencies();

    await tester.pumpWidget(const App());
    // Allow any scheduled timers/microtasks (e.g., simulated fetch delays) to complete
    await tester.pump(const Duration(seconds: 1));

    // Verify that the root MaterialApp exists
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
