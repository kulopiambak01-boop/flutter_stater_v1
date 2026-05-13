import 'package:network_info_plus/network_info_plus.dart';

class ObdWifiDetectorService {
  final NetworkInfo _networkInfo = NetworkInfo();

  Future<bool> isConnectedToObdWifi() async {
    final wifiName = await _networkInfo.getWifiName();

    if (wifiName == null) {
      return false;
    }

    final ssid = wifiName
        .replaceAll('"', '')
        .toUpperCase();

    return ssid.contains('OBD') ||
        ssid.contains('ELM') ||
        ssid.contains('VLINK') ||
        ssid.contains('WIFI');
  }

  Future<String?> currentWifi() async {
    final wifiName =
        await _networkInfo.getWifiName();

    return wifiName?.replaceAll('"', '');
  }

  Future<String?> gatewayIp() async {
    return await _networkInfo.getWifiGatewayIP();
  }
}