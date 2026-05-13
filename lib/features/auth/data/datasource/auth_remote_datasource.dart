import 'package:flutter/foundation.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/network/api_client.dart';
import '../models/user_model.dart';

class AuthRemoteDataSource {
  final ApiClient client;

  AuthRemoteDataSource(this.client);

  Future<UserModel> login({
    required String email,
    required String password,
    required String deviceInfo,
    required String androidVersion,
    required int sdkInt,
    required String location,
  }) async {
    final response = await client.dio.get(
      '',
      queryParameters: {
        'email': email,
        'password': password,
        'device_info': deviceInfo,
        'android_version': androidVersion,
        'sdk_int': sdkInt,
        'location': location,
      },
    );

    debugPrint('RAW RESPONSE: ${response.data}');

    final json = response.data;

    if (json['status'] == 'success') {
      return UserModel.fromJson(Map<String, dynamic>.from(json['data']));
    }

    throw AuthFailure(json['message'] ?? 'Login gagal');
  }
}
