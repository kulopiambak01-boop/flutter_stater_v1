import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class ObdBluetoothSerialTransport {
  BluetoothConnection? _connection;
  bool _connected = false;
  final StreamController<String> _streamController =
      StreamController.broadcast();
  String? _connectedDeviceName;

  String _responseBuffer = '';

  bool get isConnected => _connected;
  String? get connectedDeviceName => _connectedDeviceName;
  Stream<String> get onData => _streamController.stream;

  /// Scan untuk Classic Bluetooth devices
  Future<List<Map<String, dynamic>>> scanDevices() async {
    final List<Map<String, dynamic>> devices = [];

    try {
      // Request permission dan enable bluetooth
      await FlutterBluetoothSerial.instance.requestEnable;

      // Get bonded devices
      final bondedDevices = await FlutterBluetoothSerial.instance
          .getBondedDevices();

      for (final device in bondedDevices) {
        final name = device.name?.toLowerCase() ?? '';
        final isObd =
            name.contains('obd') ||
            name.contains('elm') ||
            name.contains('vlink') ||
            name.contains('konnwei') ||
            name.contains('car');

        if (isObd || name.isNotEmpty) {
          devices.add({
            'address': device.address,
            'name': device.name ?? 'Unknown OBD',
          });
          debugPrint('📱 Found paired: ${device.name} (${device.address})');
        }
      }

      // Jika tidak ada bonded devices, scan
      if (devices.isEmpty) {
        debugPrint('🔍 Scanning for devices...');

        final List<BluetoothDiscoveryResult> results = [];
        final subscription = FlutterBluetoothSerial.instance
            .startDiscovery()
            .listen((result) {
              results.add(result);
              final name = result.device.name?.toLowerCase() ?? '';
              if (name.contains('obd') || name.contains('elm')) {
                debugPrint(
                  '📱 Found: ${result.device.name} (${result.device.address})',
                );
              }
            });

        await Future.delayed(const Duration(seconds: 6));
        await subscription.cancel();

        for (final result in results) {
          final name = result.device.name?.toLowerCase() ?? '';
          final isObd =
              name.contains('obd') ||
              name.contains('elm') ||
              name.contains('vlink') ||
              name.contains('konnwei');

          if (isObd) {
            final exists = devices.any(
              (d) => d['address'] == result.device.address,
            );
            if (!exists) {
              devices.add({
                'address': result.device.address,
                'name': result.device.name ?? 'Unknown OBD',
              });
            }
          }
        }
      }
    } catch (e) {
      debugPrint('❌ Scan error: $e');
    }

    return devices;
  }

  /// Connect ke device berdasarkan MAC address
  Future<void> connect(String macAddress) async {
    try {
      debugPrint('🔄 Connecting to $macAddress...');

      _connection = await BluetoothConnection.toAddress(macAddress);
      _connected = true;

      // Get device name
      final devices = await FlutterBluetoothSerial.instance.getBondedDevices();
      final device = devices.firstWhere((d) => d.address == macAddress);
      _connectedDeviceName = device.name;

      debugPrint('✅ Connected to ${device.name}');

      // 🔥 FIX: Setup listener untuk menerima data (gunakan stream, bukan StreamController)
      _connection!.input!
          .listen((data) {
            try {
              final raw = utf8.decode(data);
              debugPrint('📥 RAW: ${_escapeString(raw)}');

              _responseBuffer += raw;

              // Response lengkap jika ada prompt '>'
              if (_responseBuffer.contains('>')) {
                _streamController.add(_responseBuffer);
                _responseBuffer = '';
              }
            } catch (e) {
              debugPrint('❌ Parse error: $e');
            }
          })
          .onError((error) {
            debugPrint('❌ Connection error: $error');
            _connected = false;
          });

      // Tunggu stabil
      await Future.delayed(const Duration(seconds: 1));
    } catch (e) {
      debugPrint('❌ Connection failed: $e');
      _connected = false;
      rethrow;
    }
  }

  /// Kirim command ke ELM327
  Future<String> sendCommand(String command) async {
    if (_connection == null || !_connected) {
      throw Exception('Not connected');
    }

    final completer = Completer<String>();
    late StreamSubscription<String> sub;

    try {
      // Format command dengan \r
      String finalCommand = command.trim();
      if (!finalCommand.endsWith('\r')) {
        finalCommand = '$finalCommand\r';
      }

      debugPrint('📤 SEND: "${_escapeString(finalCommand)}"');

      // 🔥 FIX: Subscribe ke stream, bukan ke StreamController
      sub = _streamController.stream.listen((response) {
        debugPrint('📥 GOT: "${_escapeString(response)}"');

        if (!completer.isCompleted) {
          final cleaned = _cleanResponse(response);
          completer.complete(cleaned);
        }
      });

      // Kirim command
      _connection!.output.add(utf8.encode(finalCommand));
      await _connection!.output.allSent;

      // Tunggu response dengan timeout
      return await completer.future.timeout(
        const Duration(seconds: 8),
        onTimeout: () {
          debugPrint('❌ TIMEOUT for command: $command');
          throw TimeoutException('No response for: $command');
        },
      );
    } catch (e) {
      rethrow;
    } finally {
      await sub.cancel();
    }
  }

  String _cleanResponse(String raw) {
    String result = raw.toUpperCase();
    // Hapus prompt '>'
    result = result.replaceAll('>', ' ');
    result = result.replaceAll('\r', ' ');
    result = result.replaceAll('\n', ' ');
    result = result.trim();

    // Ambil line yang mengandung data PID (mode 41)
    final parts = result.split(RegExp(r'\s+'));
    for (int i = 0; i < parts.length - 1; i++) {
      if (parts[i] == '41' && parts.length > i + 2) {
        // Found PID response
        final pid = parts[i + 1];
        final data1 = parts[i + 2];
        final data2 = i + 3 < parts.length ? parts[i + 3] : '';
        return '41 $pid $data1 $data2'.trim();
      }
    }

    return result;
  }

  String _escapeString(String input) {
    return input.replaceAll('\r', '\\r').replaceAll('\n', '\\n');
  }

  /// Disconnect
  Future<void> disconnect() async {
    try {
      await _connection?.close();
    } catch (_) {}
    _connected = false;
    _connection = null;
    debugPrint('🔌 Disconnected');
  }

  /// Dispose
  Future<void> dispose() async {
    await disconnect();
    await _streamController.close();
  }
}
