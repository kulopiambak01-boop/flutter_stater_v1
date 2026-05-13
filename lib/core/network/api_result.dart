import '../error/failure.dart';

class ApiResult<T> {
  final T? data;
  final Failure? error;

  const ApiResult.success(this.data) : error = null;

  const ApiResult.failure(this.error) : data = null;

  bool get isSuccess => data != null;
}
