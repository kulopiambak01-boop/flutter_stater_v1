import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import '../models/obd_connection_type.dart';
import '../models/obd_device.dart';

class ObdDiscoveryService {
  /// Scan untuk BLE devices
  Future<List<ObdDevice>> scanBleDevices() async {
    final List<ObdDevice> devices = [];
    StreamSubscription<List<ScanResult>>? subscription;

    try {
      if (!await FlutterBluePlus.isSupported) {
        return devices;
      }

      final adapterState = await FlutterBluePlus.adapterState.first;
      if (adapterState != BluetoothAdapterState.on) {
        return devices;
      }

      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));

      subscription = FlutterBluePlus.scanResults.listen((results) {
        for (final result in results) {
          final name = result.device.platformName.toLowerCase();
          final isObd = name.contains('obd') || name.contains('elm');

          if (isObd) {
            devices.add(
              ObdDevice(
                id: result.device.remoteId.str,
                name: result.device.platformName,
                rssi: result.rssi,
                bluetoothDevice: result.device,
                type: ObdConnectionType.bluetooth,
              ),
            );
          }
        }
      });

      await Future.delayed(const Duration(seconds: 5));
      return devices;
    } finally {
      await subscription?.cancel();
      await FlutterBluePlus.stopScan();
    }
  }

  /// Scan untuk Classic Bluetooth devices (pakai flutter_bluetooth_serial)
  Future<List<ObdDevice>> scanClassicDevices() async {
    final List<ObdDevice> devices = [];

    try {
      FlutterBluetoothSerial.instance.requestEnable;
      final bondedDevices = await FlutterBluetoothSerial.instance
          .getBondedDevices();

      for (final device in bondedDevices) {
        final name = device.name?.toLowerCase() ?? '';
        final isObd =
            name.contains('obd') ||
            name.contains('elm') ||
            name.contains('vlink') ||
            name.contains('car');

        if (isObd) {
          devices.add(
            ObdDevice(
              id: device.address,
              name: device.name ?? 'OBD Device',
              rssi: -50,
              bluetoothDevice: null,
              type: ObdConnectionType.bluetooth,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Classic BT scan error: $e');
    }

    return devices;
  }

  /// Scan semua devices
  Future<List<ObdDevice>> scanDevices() async {
    final bleDevices = await scanBleDevices();
    final classicDevices = await scanClassicDevices();

    final allDevices = [...bleDevices, ...classicDevices];
    final ids = <String>{};

    return allDevices.where((d) => ids.add(d.id)).toList();
  }
}
