import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'obd_connection_type.dart';

class ObdDevice {
  final String id;

  final String name;

  final int rssi;

  /// BLUETOOTH DEVICE
  final BluetoothDevice? bluetoothDevice;

  /// WIFI CONFIG
  final String? ipAddress;

  final int? port;

  final ObdConnectionType type;

  const ObdDevice({
    required this.id,
    required this.name,
    required this.rssi,
    required this.type,
    this.bluetoothDevice,
    this.ipAddress,
    this.port,
  });

  bool get isBluetooth => type == ObdConnectionType.bluetooth;

  bool get isWifi => type == ObdConnectionType.wifi;

  bool get isValid {
    if (type == ObdConnectionType.bluetooth) {
      return bluetoothDevice != null;
    } else if (type == ObdConnectionType.wifi) {
      return ipAddress != null && ipAddress!.isNotEmpty;
    }
    return false;
  }
}

class ObdWifiConfig {
  final String ip;

  final int port;

  const ObdWifiConfig({required this.ip, this.port = 35000});
}
