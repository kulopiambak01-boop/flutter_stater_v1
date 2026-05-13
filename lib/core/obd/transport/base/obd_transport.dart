import 'dart:async';

/// Abstract base class untuk OBD transport (Bluetooth/WiFi)
///
/// Generic type T adalah tipe target device:
/// - Bluetooth: [BluetoothDevice]
/// - WiFi: [Map<String, dynamic>] berisi host dan port
abstract class ObdTransport<T> {
  /// Cek apakah sedang terhubung
  bool get isConnected;

  /// Nama device yang terhubung (untuk UI display)
  String? get connectedDeviceName;

  /// Stream untuk menerima response dari ELM327
  Stream<String> get onData;

  /// Connect ke device dengan target spesifik
  Future<void> connect(T target);

  /// Kirim command ke ELM327 dan return response
  ///
  /// [command] - Command OBD/ELM327 (tanpa terminator \r)
  /// Returns: Response string yang sudah dibersihkan
  /// Throws: [TimeoutException] jika tidak ada response dalam 5 detik
  /// Throws: [Exception] jika koneksi bermasalah
  Future<String> sendCommand(String command);

  /// Disconnect dari device
  Future<void> disconnect();

  /// Dispose resources (stream, socket, dll)
  Future<void> dispose();
}

/// ============================
/// DEFAULT IMPLEMENTATION NOTES
/// ============================

/// Bluetooth Implementation:
/// - Gunakan FlutterBluePlus
/// - Cari characteristic dengan properti write dan notify
/// - Set notify value ke true untuk menerima response
/// - Kirim command dengan terminator '\r'
/// - Response selesai ketika menerima karakter '>'
///
/// WiFi Implementation:
/// - Gunakan Socket.connect(host, port)
/// - Kirim command dengan terminator '\r'
/// - Response selesai ketika menerima karakter '>'
/// - Default port: 35000 (ELM327 WiFi)

/// ============================
/// CONNECTION CONSTANTS
/// ============================

class ObdTransportConstants {
  /// Default timeout untuk koneksi (detik)
  static const int connectionTimeoutSeconds = 10;

  /// Default timeout untuk sendCommand (detik)
  static const int commandTimeoutSeconds = 5;

  /// ELM327 command terminator
  static const String commandTerminator = '\r';

  /// ELM327 response end marker
  static const String responseEndMarker = '>';

  /// Default WiFi port untuk ELM327
  static const int defaultWifiPort = 35000;

  /// Delay antara command (ms)
  static const int interCommandDelayMs = 120;

  /// Max retry untuk sendCommand
  static const int maxRetries = 2;
}

/// ============================
/// CONNECTION EXCEPTIONS
/// ============================

/// Exception ketika koneksi timeout
class ObdConnectionTimeoutException implements Exception {
  final String message;
  const ObdConnectionTimeoutException(this.message);
  @override
  String toString() => 'ObdConnectionTimeoutException: $message';
}

/// Exception ketika characteristic tidak ditemukan (Bluetooth)
class ObdCharacteristicNotFoundException implements Exception {
  final String message;
  const ObdCharacteristicNotFoundException(this.message);
  @override
  String toString() => 'ObdCharacteristicNotFoundException: $message';
}

/// Exception ketika ELM327 merespon error
class ObdErrorResponseException implements Exception {
  final String response;
  const ObdErrorResponseException(this.response);
  @override
  String toString() => 'ObdErrorResponseException: $response';
}
