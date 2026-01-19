import 'package:flutter/material.dart';

import 'package:cd_shop/core/theme/app_theme.dart';
import 'package:cd_shop/core/constants/app_strings.dart';
import 'package:cd_shop/router/app_router.dart';

/// Main application widget
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,

      // Theme
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,

      // Routing
      routerConfig: AppRouter.router,
    );
  }
}
