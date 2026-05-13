import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../../helpers/obd_response_cleaner.dart';

import '../base/obd_transport.dart';

class ObdBluetoothTransport implements ObdTransport<BluetoothDevice> {
  BluetoothDevice? _device;

  BluetoothCharacteristic? _writeChar;

  BluetoothCharacteristic? _notifyChar;

  StreamSubscription<List<int>>? _notifySubscription;

  final StreamController<String> _streamController =
      StreamController.broadcast();

  bool _connected = false;

  bool _busy = false;

  @override
  bool get isConnected => _connected;

  @override
  String? get connectedDeviceName => _device?.platformName;

  @override
  Stream<String> get onData => _streamController.stream;

  @override
  Future<void> connect(BluetoothDevice target) async {
    try {
      final device = target;
      _device = device;

      await device.connect(timeout: const Duration(seconds: 10));

      // 🔥 FIX #1: Tambahkan delay setelah koneksi Bluetooth
      await Future.delayed(const Duration(milliseconds: 500));

      final services = await device.discoverServices();
      await _discoverCharacteristics(services);

      if (_writeChar == null) {
        throw Exception('Write characteristic not found');
      }
      if (_notifyChar == null) {
        throw Exception('Notify characteristic not found');
      }

      await _startNotification();

      // 🔥 FIX #2: Tambahkan delay setelah notification setup
      await Future.delayed(const Duration(milliseconds: 300));

      // 🔥 FIX #3: Kirim command dummy untuk "wake up" ELM327
      await _sendRawCommand('AT\r');
      await Future.delayed(const Duration(milliseconds: 200));

      _connected = true;
      debugPrint('OBD Bluetooth connected');
    } catch (e) {
      _connected = false;
      rethrow;
    }
  }

  Future<void> _sendRawCommand(String command) async {
    final bytes = utf8.encode(command);
    await _writeChar!.write(bytes);
    debugPrint('📤 RAW SENT: ${command.replaceAll('\r', '\\r')}');
  }

  Future<void> _discoverCharacteristics(List<BluetoothService> services) async {
    for (final service in services) {
      debugPrint('🔍 Service UUID: ${service.uuid}');

      for (final c in service.characteristics) {
        debugPrint('  📍 Characteristic: ${c.uuid}');
        debugPrint(
          '     Properties: write=${c.properties.write}, '
          'writeNoResp=${c.properties.writeWithoutResponse}, '
          'notify=${c.properties.notify}, '
          'indicate=${c.properties.indicate}',
        );

        /// WRITE - prioritaskan yang punya write property
        if (c.properties.write || c.properties.writeWithoutResponse) {
          if (_writeChar == null) {
            _writeChar = c;
            debugPrint('  ✅ Selected WRITE characteristic: ${c.uuid}');
          }
        }

        /// NOTIFY
        if (c.properties.notify || c.properties.indicate) {
          if (_notifyChar == null) {
            _notifyChar = c;
            debugPrint('  ✅ Selected NOTIFY characteristic: ${c.uuid}');
          }
        }
      }
    }

    if (_writeChar == null) {
      debugPrint('❌ CRITICAL: No write characteristic found!');
    }
    if (_notifyChar == null) {
      debugPrint('❌ CRITICAL: No notify characteristic found!');
    }
  }

  Future<void> _startNotification() async {
    if (_notifyChar == null) return;

    await _notifyChar!.setNotifyValue(true);

    await _notifySubscription?.cancel();

    _notifySubscription = _notifyChar!.lastValueStream.listen((data) {
      try {
        final raw = utf8.decode(data);

        if (raw.trim().isEmpty) {
          return;
        }

        _streamController.add(raw);
      } catch (e) {
        debugPrint('NOTIFY PARSE ERROR => $e');
      }
    });
  }

  @override
  Future<String> sendCommand(String command) async {
    while (_busy) {
      await Future.delayed(const Duration(milliseconds: 30));
    }
    _busy = true;

    final completer = Completer<String>();
    late StreamSubscription sub;
    final buffer = StringBuffer();

    try {
      // 🔥 FIX #5: Pastikan command diakhiri dengan \r
      String finalCommand = command;
      if (!finalCommand.endsWith('\r')) {
        finalCommand = '$command\r';
      }

      final bytes = utf8.encode(finalCommand);
      await _writeChar!.write(bytes);
      debugPrint('📤 SENT: ${finalCommand.replaceAll('\r', '\\r')}');

      buffer.clear();

      sub = onData.listen((event) {
        buffer.write(event);
        final raw = buffer.toString();
        debugPrint(
          '📥 RAW: ${raw.replaceAll('\r', '\\r').replaceAll('\n', '\\n')}',
        );

        // 🔥 FIX #6: Cek multiple end markers
        if (raw.contains('>') || raw.contains('\r\n>') || raw.contains('\n>')) {
          final cleaned = ObdResponseCleaner.clean(raw);
          if (!completer.isCompleted) {
            debugPrint('📥 RESPONSE: $cleaned');
            completer.complete(cleaned);
          }
        }
      });

      return await completer.future.timeout(
        const Duration(
          seconds: 8,
        ), // 🔥 FIX #7: Tambah timeout untuk ATZ (8 detik)
        onTimeout: () {
          throw TimeoutException(
            'No response from ELM327 for command: $command',
          );
        },
      );
    } catch (e) {
      rethrow;
    } finally {
      _busy = false;
      await sub.cancel();
    }
  }

  @override
  Future<void> disconnect() async {
    try {
      await _notifySubscription?.cancel();

      if (_device != null) {
        await _device!.disconnect();
      }
    } catch (_) {}

    _connected = false;

    debugPrint('OBD Bluetooth disconnected');
  }

  @override
  Future<void> dispose() async {
    await disconnect();

    await _streamController.close();
  }
}
