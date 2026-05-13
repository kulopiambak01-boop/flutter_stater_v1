import '../../../../core/network/api_result.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<ApiResult<User>> login({
    required String email,
    required String password,
    required String deviceInfo,
    required String androidVersion,
    required int sdkInt,
    required String location,
  });
}
