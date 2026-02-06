import 'package:flutter/material.dart';
import 'package:talker_flutter/talker_flutter.dart';

import 'package:cd_shop/core/constants/app_strings.dart';
import 'package:cd_shop/core/services/analytics_service.dart';
import 'package:cd_shop/core/theme/app_theme.dart';
import 'package:cd_shop/injection_container.dart';
import 'package:cd_shop/router/app_router.dart';

/// Main application widget
class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final _appRouter = AppRouter();

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
      routerConfig: _appRouter.config(
        navigatorObservers: () => [
          TalkerRouteObserver(sl<Talker>()),
          sl<AnalyticsService>().observer,
        ],
      ),
    );
  }
}
