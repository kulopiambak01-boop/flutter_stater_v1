import '../../../../core/network/api_result.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<ApiResult<User>> call({
    required String email,
    required String password,
    required String deviceInfo,
    required String androidVersion,
    required int sdkInt,
    required String location,
  }) {
    return repository.login(
      email: email,
      password: password,
      deviceInfo: deviceInfo,
      androidVersion: androidVersion,
      sdkInt: sdkInt,
      location: location,
    );
  }
}
