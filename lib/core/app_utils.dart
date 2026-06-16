import 'package:flutter/material.dart';

import 'app_error.dart';

class AppSnackBar {
  const AppSnackBar._();

  static void show(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: duration,
          action: action,
        ),
      );
  }

  static void showSuccess(BuildContext context, String message) {
    show(context, message);
  }

  static void showError(
    BuildContext context,
    Object error, {
    String fallback = 'Something went wrong. Please try again.',
  }) {
    show(context, userMessageFromError(error, fallback: fallback));
  }
}

class AppDialogs {
  const AppDialogs._();

  static Future<bool> confirm(
    BuildContext context, {
    required String title,
    required String message,
    String cancelLabel = 'Cancel',
    String confirmLabel = 'Confirm',
    bool destructive = false,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(cancelLabel),
          ),
          destructive
              ? FilledButton.tonalIcon(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  icon: const Icon(Icons.warning_amber_rounded),
                  label: Text(confirmLabel),
                )
              : ElevatedButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: Text(confirmLabel),
                ),
        ],
      ),
    );

    return confirmed == true;
  }

  static Future<bool> showEmailVerification(
    BuildContext context, {
    required String email,
  }) async {
    final verified = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Verify your email'),
        content: Text(
          'We sent a verification email to $email. Please verify your email before opening the app.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Not yet'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('I verified'),
          ),
        ],
      ),
    );

    return verified == true;
  }
}
