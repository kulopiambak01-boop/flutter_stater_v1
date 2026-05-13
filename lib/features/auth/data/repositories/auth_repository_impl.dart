import 'package:dio/dio.dart';
import 'package:flutter_starter/core/error/failure.dart';

import '../../../../core/error/error_handler.dart';
import '../../../../core/network/api_result.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasource/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;

  AuthRepositoryImpl(this.remote);

  @override
  Future<ApiResult<User>> login({
    required String email,
    required String password,
    required String deviceInfo,
    required String androidVersion,
    required int sdkInt,
    required String location,
  }) async {
    try {
      final result = await remote.login(
        email: email,
        password: password,
        deviceInfo: deviceInfo,
        androidVersion: androidVersion,
        sdkInt: sdkInt,
        location: location,
      );

      return ApiResult<User>.success(result);
    } on DioException catch (e) {
      final failure = ErrorHandler.handle(e);

      return ApiResult<User>.failure(failure);
    } on Failure catch (e) {
      return ApiResult<User>.failure(e);
    } catch (e) {
      return ApiResult<User>.failure(ServerFailure(e.toString()));
    }
  }
}
