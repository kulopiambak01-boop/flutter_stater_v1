import 'package:dio/dio.dart';

import 'failure.dart';

class ErrorHandler {
  static Failure handle(dynamic error) {
    if (error is DioException) {
      if (error.type == DioExceptionType.connectionTimeout) {
        return const NetworkFailure("Connection timeout");
      }

      if (error.response != null) {
        return ServerFailure("Server error: ${error.response?.statusCode}");
      }

      return const NetworkFailure("Network error");
    }

    return const ServerFailure("Unexpected error");
  }
}
