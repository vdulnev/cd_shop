import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cd_shop/app.dart';
import 'package:cd_shop/injection_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependencies
  await initDependencies();

  runApp(const ProviderScope(child: App()));
}
