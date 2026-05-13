import 'dart:async';

import 'package:flutter/foundation.dart';

import '../controllers/obd_sender.dart';
import '../protocol/obd_command.dart';

class ObdCommandService {
  bool _busy = false;

  /// 🔥 FIX: Tambahkan default timeout
  static const Duration _defaultTimeout = Duration(seconds: 5);

  /// 🔥 FIX: Tambahkan retry count
  static const int _maxRetries = 2;

  Future<String> sendCommand({
    required ObdSender send,
    required String command,
    Duration timeout = _defaultTimeout,
    int retries = _maxRetries,
  }) async {
    int attempt = 0;

    while (true) {
      while (_busy) {
        await Future.delayed(const Duration(milliseconds: 40));
      }

      _busy = true;

      try {
        // 🔥 FIX: Tambahkan timeout wrapper
        final result = await send(command).timeout(
          timeout,
          onTimeout: () {
            throw TimeoutException(
              'Command "$command" timed out after ${timeout.inMilliseconds}ms',
            );
          },
        );

        return result;
      } catch (e) {
        attempt++;

        // 🔥 FIX: Retry logic untuk timeout atau error tertentu
        final isRetriable =
            e is TimeoutException ||
            e.toString().contains('NO DATA') ||
            e.toString().contains('BUS ERROR');

        if (attempt >= retries || !isRetriable) {
          debugPrint(
            '[OBD COMMAND FAILED] $command => Attempts: $attempt, Error: $e',
          );
          rethrow;
        }

        debugPrint(
          '[OBD COMMAND RETRY] $command => Attempt $attempt of $retries',
        );
        await Future.delayed(
          Duration(milliseconds: 500 * attempt),
        ); // exponential backoff
      } finally {
        _busy = false;
      }
    }
  }

  /// =========================
  /// INITIALIZE ELM327
  /// =========================

  Future<void> initialize({required ObdSender send}) async {
    debugPrint('[OBD INIT] Start');

    // 🔥 FIX #1: Tambahkan delay sebelum command pertama
    await Future.delayed(const Duration(milliseconds: 500));

    // 🔥 FIX #2: Retry untuk ATZ dengan timeout lebih panjang
    bool resetSuccess = false;

    for (int i = 0; i < 3; i++) {
      try {
        debugPrint('[OBD INIT] ATZ attempt ${i + 1}/3');

        await sendCommand(
          send: send,
          command: ObdCommands.reset,
          timeout: const Duration(seconds: 8),
          retries: 1,
        );

        resetSuccess = true;
        debugPrint('[OBD INIT] ATZ success');
        break;
      } catch (e) {
        debugPrint('[OBD INIT] ATZ attempt $i failed: $e');
        await Future.delayed(const Duration(seconds: 1));
      }
    }

    if (!resetSuccess) {
      debugPrint('[OBD INIT] ATZ all attempts failed, but continuing...');
    }

    await Future.delayed(const Duration(seconds: 2));

    final setupCommands = [
      ObdCommands.echoOff,
      ObdCommands.lineFeedOff,
      ObdCommands.headersOff,
      ObdCommands.spacesOn,
      ObdCommands.adaptiveTiming,
      ObdCommands.allowLongMessages,
      ObdCommands.autoProtocol,
    ];

    for (final cmd in setupCommands) {
      try {
        await sendCommand(
          send: send,
          command: cmd,
          timeout: const Duration(seconds: 3),
          retries: 1,
        );
        debugPrint('[OBD INIT] Success: $cmd');
      } catch (e) {
        debugPrint('[OBD INIT] Failed: $cmd - $e (continuing...)');
      }

      await Future.delayed(const Duration(milliseconds: 200));
    }

    // Get protocol (optional, jangan gagalkan init)
    try {
      final protocol = await sendCommand(
        send: send,
        command: ObdCommands.describeProtocol,
        timeout: const Duration(seconds: 3),
        retries: 1,
      );
      debugPrint('[OBD INIT] Protocol => $protocol');
    } catch (e) {
      debugPrint('[OBD INIT] Protocol detection failed: $e');
    }

    debugPrint('[OBD INIT] Complete');
  }

  /// =========================
  /// PID HELPERS
  /// =========================

  Future<String> rpm({required ObdSender send}) {
    return sendCommand(send: send, command: ObdCommands.rpm);
  }

  Future<String> speed({required ObdSender send}) {
    return sendCommand(send: send, command: ObdCommands.speed);
  }

  Future<String> coolant({required ObdSender send}) {
    return sendCommand(send: send, command: ObdCommands.coolantTemp);
  }

  Future<String> engineLoad({required ObdSender send}) {
    return sendCommand(send: send, command: ObdCommands.engineLoad);
  }

  Future<String> fuel({required ObdSender send}) {
    return sendCommand(send: send, command: ObdCommands.fuelLevel);
  }

  Future<String> maf({required ObdSender send}) {
    return sendCommand(send: send, command: ObdCommands.maf);
  }

  Future<String> battery({required ObdSender send}) {
    // 🔥 FIX: Gunakan ATRV untuk voltage (ELM327 internal)
    // Atau bisa juga pakai PID 0142 tergantung kebutuhan
    return sendCommand(send: send, command: ObdCommands.voltage);
  }

  Future<String> supportedPid({required ObdSender send}) {
    return sendCommand(send: send, command: ObdCommands.supportedPidA);
  }

  /// =========================
  /// KEEP ALIVE
  /// =========================

  Future<void> keepAlive({required ObdSender send}) async {
    try {
      await sendCommand(
        send: send,
        command: 'AT',
        timeout: const Duration(seconds: 2),
        retries: 1,
      );
    } catch (e) {
      debugPrint('[OBD KEEP ALIVE] Failed: $e');
    }
  }
}
