import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cd_shop/core/models/repository_event.dart';
import 'package:cd_shop/core/providers/app_event_provider.dart';
import 'package:cd_shop/core/widgets/snackbar_helper.dart';

/// Widget that listens to app-level repository events and shows snackbars
class AppEventWidget extends ConsumerWidget {
  const AppEventWidget({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(appEventProvider, (previous, next) {
      next.whenOrNull(
        data: (event) {
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
            case AddressSuccessEvent(:final message):
              showSuccessSnackBar(context, message: message);
            case AddressErrorEvent(:final message):
              showErrorSnackBar(context, message: message);
          }
        },
      );
    });

    return child;
  }
}
