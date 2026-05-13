import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/data/datasource/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecase/login_usecase.dart';
import '../network/api_client.dart';
import '../services/device_service.dart';
import '../services/location_service.dart';
import '../services/permission_service.dart';
import '../services/theme_service.dart';

final dioProvider = Provider((ref) => Dio());

final apiClientProvider = Provider((ref) => ApiClient(ref.read(dioProvider)));

final authRemoteProvider = Provider(
  (ref) => AuthRemoteDataSource(ref.read(apiClientProvider)),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(ref.read(authRemoteProvider)),
);

final loginUseCaseProvider = Provider(
  (ref) => LoginUseCase(ref.read(authRepositoryProvider)),
);

final deviceInfoPluginProvider = Provider((ref) => DeviceInfoPlugin());

final deviceServiceProvider = Provider(
  (ref) => DeviceService(ref.read(deviceInfoPluginProvider)),
);

final locationServiceProvider = Provider((ref) => LocationService());

final permissionServiceProvider = Provider((ref) => PermissionService());

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(ThemeService.currentMode),
);

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier(super.state);

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;

    await ThemeService.saveThemeMode(mode);
  }

  Future<void> toggleThemeMode() async {
    final nextMode = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;

    await setThemeMode(nextMode);
  }
}
