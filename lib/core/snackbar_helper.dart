import 'package:flutter/material.dart';

/// Helper class for showing SnackBars at the top of the screen
class SnackBarHelper {
  /// Shows a success SnackBar at the top of the screen
  static void showSuccess(BuildContext context, String message) {
    _showSnackBar(context, message, isError: false);
  }

  /// Shows an error SnackBar at the top of the screen with red background
  static void showError(BuildContext context, String message) {
    _showSnackBar(context, message, isError: true);
  }

  static void _showSnackBar(BuildContext context, String message,
      {required bool isError}) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : null,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height - 150,
          left: 16,
          right: 16,
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
