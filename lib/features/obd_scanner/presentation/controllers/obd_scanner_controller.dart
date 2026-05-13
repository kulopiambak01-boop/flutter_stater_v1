import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/obd/models/obd_connection_type.dart';
import '../../../../core/obd/models/obd_device.dart';
import '../../../../core/obd/providers/obd_provider.dart';
import '../../../../core/obd/transport/base/obd_transport.dart';

final obdScannerControllerProvider =
    StateNotifierProvider<ObdScannerController, AsyncValue<List<ObdDevice>>>((
      ref,
    ) {
      return ObdScannerController(ref);
    });

class ObdScannerController extends StateNotifier<AsyncValue<List<ObdDevice>>> {
  final Ref _ref;
  String? _connectingDeviceId;
  String? _connectedDeviceId;

  String? get connectingDeviceId => _connectingDeviceId;
  String? get connectedDeviceId => _connectedDeviceId;

  ObdScannerController(this._ref) : super(const AsyncData([]));

  bool _scanning = false;

  bool get isScanning => _scanning;

  Future<void> scan() async {
    if (_scanning) return;

    _scanning = true;

    try {
      state = const AsyncLoading();

      /// cleanup previous session
      await disconnect(silent: true);

      final discovery = _ref.read(obdDiscoveryProvider);
      final devices = await discovery.scanDevices();

      state = AsyncData(_removeDuplicate(devices));
    } catch (e, st) {
      state = AsyncError(e, st);
    } finally {
      _scanning = false;
    }
  }

  Future<void> connect(ObdDevice device) async {
    try {
      _connectingDeviceId = device.id;
      state = AsyncData(state.value ?? []); // trigger rebuild

      await disconnect(silent: true);

      // 🔥 FIX #1: Simpan transport ke variable terlebih dahulu
      final transport = await _createTransport(device);

      if (transport == null) {
        throw Exception(
          'Failed to create transport for device: ${device.name}',
        );
      }

      // 🔥 FIX #2: Gunakan ObdTransport type untuk provider
      _ref.read(activeObdTransportProvider.notifier).state = transport;

      final command = _ref.read(obdCommandProvider);

      // 🔥 FIX #3: Initialize dengan sendCommand dari transport
      await command.initialize(send: transport.sendCommand);

      // 🔥 FIX #4: Start live data controller
      await _ref
          .read(obdLiveDataControllerProvider.notifier)
          .start(send: transport.sendCommand);

      _connectedDeviceId = device.id;

      debugPrint('✅ Connected to device: ${device.name}');
    } catch (e) {
      debugPrint('❌ Connection failed: $e');
      // 🔥 FIX #5: Update state dengan error
      state = AsyncError(e, StackTrace.current);
      rethrow;
    } finally {
      _connectingDeviceId = null;
      state = AsyncData(state.value ?? []); // trigger rebuild lagi
    }
  }

  Future<ObdTransport?> _createTransport(ObdDevice device) async {
    switch (device.type) {
      case ObdConnectionType.wifi:
        // 🔥 FIX #6: Validasi WiFi credentials
        if (device.ipAddress == null || device.ipAddress!.isEmpty) {
          debugPrint('❌ WiFi device missing IP address');
          return null;
        }

        final transport = _ref.read(obdWifiTransportProvider);

        try {
          await transport.connect({
            'host': device.ipAddress!,
            'port': device.port ?? 35000,
          });
          debugPrint('✅ WiFi transport created for ${device.ipAddress}');
          return transport;
        } catch (e) {
          debugPrint('❌ WiFi connection failed: $e');
          return null;
        }

      case ObdConnectionType.bluetooth:
        // 🔥 FIX #7: Validasi bluetooth device tidak null
        if (device.bluetoothDevice == null) {
          debugPrint('❌ Bluetooth device is null for: ${device.name}');
          return null;
        }

        final transport = _ref.read(obdBluetoothTransportProvider);

        try {
          await transport.connect(device.bluetoothDevice!);
          debugPrint('✅ Bluetooth transport created for ${device.name}');
          return transport;
        } catch (e) {
          debugPrint('❌ Bluetooth connection failed: $e');
          return null;
        }
    }
  }

  Future<void> disconnect({bool silent = false}) async {
    try {
      await _ref.read(obdLiveDataControllerProvider.notifier).stop();

      final transport = _ref.read(activeObdTransportProvider);

      if (transport != null) {
        await transport.disconnect();
        debugPrint('✅ Disconnected from device');
      }

      _ref.read(activeObdTransportProvider.notifier).state = null;
      _connectedDeviceId = null;

      if (!silent) {
        state = AsyncData(state.value ?? []);
      }
    } catch (e) {
      debugPrint('❌ Disconnect error: $e');
    }
  }

  List<ObdDevice> _removeDuplicate(List<ObdDevice> devices) {
    final ids = <String>{};
    return devices.where((device) {
      if (ids.contains(device.id)) {
        return false;
      }
      ids.add(device.id);
      return true;
    }).toList();
  }

  @override
  void dispose() {
    disconnect(silent: true);
    super.dispose();
  }
}
