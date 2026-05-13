class ObdRetryService {
  static Future<T> retry<T>({
    required Future<T> Function() task,
    int maxRetry = 3,
    Duration delay = const Duration(seconds: 2),
  }) async {
    int attempt = 0;

    while (true) {
      try {
        return await task();
      } catch (_) {
        attempt++;

        if (attempt >= maxRetry) {
          rethrow;
        }

        await Future.delayed(delay);
      }
    }
  }
}
