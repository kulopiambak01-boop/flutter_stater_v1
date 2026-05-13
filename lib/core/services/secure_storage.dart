import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage();

  static Future<void> saveToken(String token) async {
    await _storage.write(key: 'token', value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: 'token');
  }

  static Future<void> setLoggedIn(bool value) async {
    await _storage.write(key: 'is_logged_in', value: value.toString());
  }

  static Future<bool> isLoggedIn() async {
    final value = await _storage.read(key: 'is_logged_in');

    return value == 'true';
  }

  static Future<void> saveThemeMode(ThemeMode mode) async {
    await _storage.write(key: 'theme_mode', value: mode.name);
  }

  static Future<ThemeMode> getThemeMode() async {
    final value = await _storage.read(key: 'theme_mode');

    switch (value) {
      case 'dark':
        return ThemeMode.dark;

      case 'light':
        return ThemeMode.light;

      default:
        return ThemeMode.light;
    }
  }

  static Future<void> clear() async {
    await _storage.deleteAll();
  }
}
