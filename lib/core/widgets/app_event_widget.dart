import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cd_shop/core/blocs/app_event_bloc.dart';
import 'package:cd_shop/core/models/repository_event.dart';
import 'package:cd_shop/core/widgets/snackbar_helper.dart';

/// Widget that listens to app-level repository events and shows snackbars
class AppEventWidget extends StatelessWidget {
  const AppEventWidget({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppEventBloc, RepositoryEvent?>(
      listener: (context, event) {
        if (event == null) return;

        switch (event) {
          case AuthSuccessEvent(:final message):
            showSuccessSnackBar(context, message: message);
          case AuthErrorEvent(:final message):
            showErrorSnackBar(context, message: message);
          case CartSuccessEvent(:final message):
            showSuccessSnackBar(context, message: message);
          case CartErrorEvent(:final message):
            showErrorSnackBar(context, message: message);
          case ProductSuccessEvent(:final message):
            showSuccessSnackBar(context, message: message);
          case ProductErrorEvent(:final message):
            showErrorSnackBar(context, message: message);
        }
      },
      child: child,
    );
  }
}
