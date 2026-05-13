import 'package:flutter/material.dart';

class AppDialog {
  static void error(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (_) =>
          AlertDialog(title: const Text("Error"), content: Text(message)),
    );
  }

  static void loading(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
  }
}
