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
            case SuccessEvent(:final message):
              showSuccessSnackBar(context, message: message);
            case ErrorEvent(:final message):
              showErrorSnackBar(context, message: message);
          }
        },
      );
    });

    return child;
  }
}
