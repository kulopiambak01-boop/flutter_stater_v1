class ObdResponseCleaner {
  static const _invalidWords = [
    'SEARCHING...',
    'STOPPED',
    'UNABLE TO CONNECT',
    'ERROR',
  ];

  static String clean(String raw) {
    String result = raw.toUpperCase();

    for (final word in _invalidWords) {
      result = result.replaceAll(word, ' ');
    }

    return result
        .replaceAll('\r', ' ')
        .replaceAll('\n', ' ')
        .replaceAll('>', ' ')
        .trim();
  }

  static bool isNoData(String raw) {
    return raw.toUpperCase().contains('NO DATA');
  }
}
