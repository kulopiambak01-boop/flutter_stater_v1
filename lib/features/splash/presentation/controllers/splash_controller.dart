import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../core/providers/app_provider.dart';

final splashControllerProvider =
    StateNotifierProvider<SplashController, AsyncValue<void>>(
      (ref) => SplashController(ref),
    );

class SplashController extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  SplashController(this.ref) : super(const AsyncLoading());

  Future<void> initialize(BuildContext context) async {
    try {
      final permission = ref.read(permissionServiceProvider);

      final location = ref.read(locationServiceProvider);

      final device = ref.read(deviceServiceProvider);

      /// permission
      await permission.handleLocationPermission();

      /// device info
      final deviceInfo = await device.getDeviceInfo();

      /// location
      final position = await location.loadCurrentLocation();

      debugPrint('Device: $deviceInfo');

      debugPrint(
        'Location: '
        '${position.latitude}, '
        '${position.longitude}',
      );

      await Future.delayed(const Duration(seconds: 2));

      state = const AsyncData(null);

      if (context.mounted) {
        context.go(AppRoutes.login);
      }
    } catch (e, s) {
      state = AsyncError(e, s);
    }
  }
}
