import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../helpers/obd_response_cleaner.dart';

import '../base/obd_transport.dart';

class ObdWifiTransport implements ObdTransport<Map<String, dynamic>> {
  Socket? _socket;

  StreamSubscription<List<int>>? _socketSubscription;

  final StreamController<String> _streamController =
      StreamController.broadcast();

  bool _connected = false;

  bool _busy = false;

  String? _host;

  @override
  bool get isConnected => _connected;

  @override
  String? get connectedDeviceName => _host;

  @override
  Stream<String> get onData => _streamController.stream;

  @override
  Future<void> connect(Map<String, dynamic> target) async {
    try {
      final data = target;

      final host = data['host'];

      final port = data['port'];

      _host = host;

      _socket = await Socket.connect(
        host,
        port,
        timeout: const Duration(seconds: 10),
      );

      await _startSocketListener();

      _connected = true;

      debugPrint('OBD WiFi connected');
    } catch (e) {
      _connected = false;

      rethrow;
    }
  }

  Future<void> _startSocketListener() async {
    await _socketSubscription?.cancel();

    _socketSubscription = _socket!.listen(
      (data) {
        try {
          final raw = utf8.decode(data);

          if (raw.trim().isEmpty) {
            return;
          }

          _streamController.add(raw);
        } catch (e) {
          debugPrint('SOCKET PARSE ERROR => $e');
        }
      },

      onDone: () {
        debugPrint('WiFi socket disconnected');

        _connected = false;
      },

      onError: (e) {
        debugPrint('WiFi socket error => $e');

        _connected = false;
      },

      cancelOnError: true,
    );
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
      final commandWithTerminator = '$command\r';
      _socket!.write(commandWithTerminator);
      await _socket!.flush();
      debugPrint('📤 SENT (WiFi): $commandWithTerminator');

      buffer.clear();

      sub = onData.listen((event) {
        buffer.write(event);
        final raw = buffer.toString();

        if (raw.contains('>')) {
          final cleaned = ObdResponseCleaner.clean(raw);
          if (!completer.isCompleted) {
            debugPrint('📥 RESPONSE (WiFi): $cleaned');
            completer.complete(cleaned);
          }
        }
      });

      return await completer.future.timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw TimeoutException(
            'No response from ELM327 WiFi for command: $command',
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
      await _socketSubscription?.cancel();

      await _socket?.flush();

      await _socket?.close();

      _socket?.destroy();
    } catch (_) {}

    _connected = false;

    debugPrint('OBD WiFi disconnected');
  }

  @override
  Future<void> dispose() async {
    await disconnect();

    await _streamController.close();
  }
}
