import 'package:flutter/material.dart';

/// Unified snackbar display helper with auto-dismiss and no stacking
void showAppSnackBar(
  BuildContext context, {
  required String message,
  Color backgroundColor = Colors.grey,
  Duration duration = const Duration(seconds: 2),
  SnackBarAction? action,
  bool useFloating = true,
}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.clearSnackBars();
  messenger.showSnackBar(
    SnackBar(
      content: Text(message),
      persist: false,
      backgroundColor: backgroundColor,
      duration: duration,
      behavior: useFloating ? SnackBarBehavior.floating : null,
      action: action,
    ),
  );
}

/// Show success snackbar (green)
void showSuccessSnackBar(
  BuildContext context, {
  required String message,
  SnackBarAction? action,
}) {
  showAppSnackBar(
    context,
    message: message,
    backgroundColor: Colors.green,
    action: action,
  );
}

/// Show error snackbar (red)
void showErrorSnackBar(
  BuildContext context, {
  required String message,
  SnackBarAction? action,
}) {
  showAppSnackBar(
    context,
    message: message,
    backgroundColor: Colors.red,
    action: action,
  );
}

/// Show info snackbar (default)
void showInfoSnackBar(
  BuildContext context, {
  required String message,
  SnackBarAction? action,
}) {
  showAppSnackBar(
    context,
    message: message,
    action: action,
  );
}
