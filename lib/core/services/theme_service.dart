import 'package:flutter/material.dart';

import 'secure_storage.dart';

class ThemeService {
  static ThemeMode currentMode = ThemeMode.light;

  static Future<void> init() async {
    currentMode = await SecureStorage.getThemeMode();
  }

  static Future<void> saveThemeMode(ThemeMode mode) async {
    currentMode = mode;

    await SecureStorage.saveThemeMode(mode);
  }
}
