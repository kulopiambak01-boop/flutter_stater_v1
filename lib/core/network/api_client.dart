import 'package:dio/dio.dart';

import '../config/env.dart';
import '../services/secure_storage.dart';

class ApiClient {
  final Dio dio;

  ApiClient(this.dio) {
    dio.options = BaseOptions(
      baseUrl: EnvConfig.baseUrl,

      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      receiveDataWhenStatusError: true,
      headers: {'Content-Type': 'application/json'},
    );

    dio.options.followRedirects = true;
    dio.options.validateStatus = (status) {
      return status != null && status < 400;
    };

    dio.interceptors.addAll([
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await SecureStorage.getToken();

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          handler.next(options);
        },

        onError: (e, handler) {
          handler.next(e);
        },
      ),

      LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        error: true,
      ),
    ]);
  }
}
