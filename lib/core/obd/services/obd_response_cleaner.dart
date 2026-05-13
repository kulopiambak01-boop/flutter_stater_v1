class ObdResponseCleaner {
  static const List<String> _invalidWords = [
    'SEARCHING...',
    'STOPPED',
    'UNABLE TO CONNECT',
    'ERROR',
    'BUS ERROR',
    'CAN ERROR',
    'BUFFER FULL',
    'RX ERROR',
    '?',
    '>',
  ];

  static String clean(String raw) {
    String result = raw.toUpperCase();

    for (final word in _invalidWords) {
      result = result.replaceAll(word, ' ');
    }

    // 🔥 FIX: Tambahkan pembersihan untuk karakter kontrol lainnya
    result = result
        .replaceAll('\r', ' ')
        .replaceAll('\n', ' ')
        .replaceAll('\t', ' ')
        .replaceAll('>', ' ')
        .replaceAll(RegExp(r'\s+'), ' ') // multiple spaces jadi single space
        .trim();

    return result;
  }

  static bool isNoData(String raw) {
    return raw.toUpperCase().contains('NO DATA');
  }

  /// 🔥 NEW: Helper untuk mengecek apakah response error
  static bool isErrorResponse(String raw) {
    final upper = raw.toUpperCase();
    return upper.contains('ERROR') ||
        upper.contains('UNABLE TO CONNECT') ||
        upper.contains('BUS ERROR') ||
        upper.contains('CAN ERROR') ||
        upper.contains('BUFFER FULL') ||
        upper.contains('RX ERROR') ||
        upper.contains('?');
  }

  /// 🔥 NEW: Ekstrak response tanpa prompt
  static String extractResponse(String raw) {
    final cleaned = clean(raw);
    // Hapus semua yang bukan hex atau spasi
    return cleaned.replaceAll(RegExp(r'[^0-9A-F\s]'), '').trim();
  }
}
