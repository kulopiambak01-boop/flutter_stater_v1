import 'dart:async';

import 'package:flutter/foundation.dart';

import '../controllers/obd_sender.dart';
import '../models/obd_live_data.dart';
import '../services/obd_command_service.dart';
import '../services/obd_parser_service.dart';
import '../services/obd_telemetry_service.dart';
import '../utils/obd_polling_config.dart';

class ObdStreamService {
  final ObdCommandService command;
  final ObdParserService parser;
  final ObdTelemetryService telemetry;

  ObdStreamService({
    required this.command,
    required this.parser,
    required this.telemetry,
  });

  /// =========================
  /// STREAM
  /// =========================

  final StreamController<ObdLiveData> _controller =
      StreamController.broadcast();
  Stream<ObdLiveData> get stream => _controller.stream;

  Timer? _timer;
  bool _busy = false;
  int _tick = 0;

  // Flag untuk listener
  bool _hasListener = false;

  // Simple lock tanpa async
  bool _isStarting = false;
  bool _isStopping = false;

  /// =========================
  /// CACHE VALUE
  /// =========================

  double _rpm = 0;
  double _speed = 0;
  double _coolant = 0;
  double _battery = 0;
  double _load = 0;
  double _fuel = 0;
  double _maf = 0;

  /// =========================
  /// START STREAM
  /// =========================

  void start({required ObdSender send}) {
    // 🔥 FIX: Simple lock tanpa Future
    if (_isStarting || _timer != null) {
      debugPrint('OBD stream already starting or running');
      return;
    }

    _isStarting = true;

    try {
      if (_timer != null) {
        debugPrint('OBD stream already running');
        return;
      }

      _hasListener = true;

      debugPrint('OBD realtime telemetry started');

      _timer = Timer.periodic(
        const Duration(milliseconds: 850),
        (_) => _tickStream(send),
      );
    } finally {
      _isStarting = false;
    }
  }

  /// =========================
  /// MAIN LOOP
  /// =========================

  Future<void> _tickStream(ObdSender send) async {
    // Stop polling jika tidak ada listener
    if (!_hasListener && !_controller.hasListener) {
      debugPrint('OBD stream: No listeners, pausing polling');
      _stopTimer();
      return;
    }

    if (_busy) {
      debugPrint('OBD stream: Busy, skipping tick $_tick');
      return;
    }

    _busy = true;

    try {
      /// FAST
      await _pollFast(send);

      /// MEDIUM
      if (_tick % ObdPollingConfig.mediumTick == 0) {
        await _pollMedium(send);
      }

      /// SLOW
      if (_tick % ObdPollingConfig.slowTick == 0) {
        await _pollSlow(send);
      }

      /// KEEP ALIVE
      if (_tick % ObdPollingConfig.keepAliveTick == 0) {
        await command.keepAlive(send: send);
      }

      _emit();

      _tick++;

      // Reset tick jika overflow
      if (_tick > 1000000) {
        _tick = 0;
      }
    } catch (e, st) {
      debugPrint('OBD STREAM ERROR => $e');
      debugPrintStack(stackTrace: st);
    } finally {
      _busy = false;
    }
  }

  /// =========================
  /// FAST POLLING
  /// RPM + SPEED + MAF
  /// =========================

  Future<void> _pollFast(ObdSender send) async {
    try {
      final rpmRaw = await command.rpm(send: send);
      await Future.delayed(const Duration(milliseconds: 80));

      final speedRaw = await command.speed(send: send);

      final rpm = parser.rpm(rpmRaw);
      final speed = parser.speed(speedRaw);

      if (_isValidRpm(rpm)) {
        _rpm = _smooth(_rpm, rpm);
      }

      if (_isValidSpeed(speed)) {
        _speed = _smooth(_speed, speed);
      }

      final mafRaw = await command.maf(send: send);
      final maf = parser.parseMaf(mafRaw);

      if (_isValidMaf(maf)) {
        _maf = _smooth(_maf, maf);
      }
    } catch (e) {
      debugPrint('FAST POLLING ERROR => $e');
    }
  }

  /// =========================
  /// MEDIUM POLLING
  /// COOLANT + LOAD
  /// =========================

  Future<void> _pollMedium(ObdSender send) async {
    try {
      final coolantRaw = await command.coolant(send: send);
      await Future.delayed(const Duration(milliseconds: 80));

      final loadRaw = await command.engineLoad(send: send);

      final coolant = parser.coolant(coolantRaw);
      final load = parser.engineLoad(loadRaw);

      if (_isValidCoolant(coolant)) {
        _coolant = _smooth(_coolant, coolant);
      }

      if (_isValidPercentage(load)) {
        _load = _smooth(_load, load);
      }
    } catch (e) {
      debugPrint('MEDIUM POLLING ERROR => $e');
    }
  }

  /// =========================
  /// SLOW POLLING
  /// FUEL + BATTERY
  /// =========================

  Future<void> _pollSlow(ObdSender send) async {
    try {
      final fuelRaw = await command.fuel(send: send);
      await Future.delayed(const Duration(milliseconds: 120));

      final batteryRaw = await command.battery(send: send);

      final fuel = parser.fuel(fuelRaw);
      final battery = parser.parseVoltage(batteryRaw);

      if (_isValidPercentage(fuel)) {
        _fuel = _smooth(_fuel, fuel);
      }

      if (_isValidBattery(battery)) {
        _battery = battery;
      }

      /// TELEMETRY
      telemetry.update(speed: _speed, maf: _maf);
    } catch (e) {
      debugPrint('SLOW POLLING ERROR => $e');
    }
  }

  /// =========================
  /// EMIT LIVE DATA
  /// =========================

  void _emit() {
    if (_controller.isClosed) {
      return;
    }

    _controller.add(
      ObdLiveData(
        rpm: _rpm,
        speed: _speed,
        coolantTemp: _coolant,
        batteryVoltage: _battery,
        engineLoad: _load,
        fuelLevel: _fuel,
        maf: _maf,
        tripKm: telemetry.tripKm,
        fuelUsedL: telemetry.fuelUsedL,
        avgKmL: telemetry.avgKmL,
      ),
    );
  }

  /// =========================
  /// FILTERING
  /// =========================

  double _smooth(double current, double incoming) {
    return (current * 0.4) + (incoming * 0.6);
  }

  /// =========================
  /// VALIDATION
  /// =========================

  bool _isValidRpm(double value) => value >= 0 && value <= 9000;
  bool _isValidSpeed(double value) => value >= 0 && value <= 300;
  bool _isValidCoolant(double value) => value >= -40 && value <= 140;
  bool _isValidBattery(double value) => value >= 10 && value <= 16;
  bool _isValidPercentage(double value) => value >= 0 && value <= 100;
  bool _isValidMaf(double value) => value >= 0 && value <= 400;

  /// =========================
  /// STOP
  /// =========================

  void stop() {
    if (_isStopping) return;

    _isStopping = true;

    try {
      _stopTimer();
      _hasListener = false;
      _busy = false;
      debugPrint('OBD realtime telemetry stopped');
    } finally {
      _isStopping = false;
    }
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
    _tick = 0;
  }

  /// =========================
  /// PAUSE/RESUME
  /// =========================

  void pause() {
    if (_timer != null) {
      _stopTimer();
      debugPrint('OBD stream paused');
    }
  }

  void resume({required ObdSender send}) {
    if (_timer == null && _hasListener) {
      _timer = Timer.periodic(
        const Duration(milliseconds: 850),
        (_) => _tickStream(send),
      );
      debugPrint('OBD stream resumed');
    }
  }

  /// =========================
  /// DISPOSE
  /// =========================

  void dispose() {
    stop();
    _controller.close();
    debugPrint('OBD stream service disposed');
  }
}
