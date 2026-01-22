import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cd_shop/core/blocs/app_event_bloc.dart';
import 'package:cd_shop/core/constants/app_strings.dart';
import 'package:cd_shop/core/theme/app_theme.dart';
import 'package:cd_shop/injection_container.dart';
import 'package:cd_shop/router/app_router.dart';

/// Main application widget
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AppEventBloc>(),
      child: MaterialApp.router(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,

        // Theme
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,

        // Routing
        routerConfig: AppRouter.router,
      ),
    );
  }
}
