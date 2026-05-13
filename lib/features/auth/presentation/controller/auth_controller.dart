import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/services/secure_storage.dart';
import '../../../../core/utils/loading_extention.dart';
import '../../domain/entities/user.dart';

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<User?>>(
      (ref) => AuthController(ref),
    );

class AuthController extends StateNotifier<AsyncValue<User?>> {
  final Ref ref;

  AuthController(this.ref) : super(const AsyncData(null));

  Future<void> login(String email, String password) async {
    try {
      /// loading overlay
      ref.showLoading();

      state = const AsyncLoading();

      final deviceService = ref.read(deviceServiceProvider);

      final locationService = ref.read(locationServiceProvider);

      final deviceInfo = await deviceService.getDeviceInfo();

      final deviceModel = deviceInfo['model']?.toString() ?? 'Unknown Device';

      final androidVersion = deviceInfo['androidVersion']?.toString() ?? '-';

      final sdkInt = deviceInfo['sdkInt'] ?? 0;

      final position = await locationService.loadCurrentLocation();

      final location =
          '${position.latitude},'
          '${position.longitude}';

      final usecase = ref.read(loginUseCaseProvider);

      final result = await usecase(
        email: email,
        password: password,
        deviceInfo: deviceModel,
        androidVersion: androidVersion,
        sdkInt: sdkInt,
        location: location,
      );
      if (result.isSuccess && result.data != null) {
        await SecureStorage.saveToken(result.data!.id);
        await SecureStorage.setLoggedIn(true);

        state = AsyncData(result.data);

        return;
      }

      final error = result.error ?? const AuthFailure('Login gagal');

      state = AsyncError(error, StackTrace.current);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    } finally {
      ref.hideLoading();
    }
  }
}
