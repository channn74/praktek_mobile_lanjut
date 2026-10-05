import 'package:flutter/material.dart';

import '../constants/colors.dart';

/// Helper kecil untuk menampilkan Snackbar dengan gaya yang sama.
class AppSnackBar {
  const AppSnackBar._();

  static void success(BuildContext context, String message) =>
      _show(context, message, AppColors.success);

  static void error(BuildContext context, String message) =>
      _show(context, message, AppColors.error);

  static void info(BuildContext context, String message) =>
      _show(context, message, AppColors.info);

  static void _show(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }
}
