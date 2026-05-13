import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

class DeviceService {
  final DeviceInfoPlugin _deviceInfo;

  DeviceService(this._deviceInfo);

  Future<Map<String, dynamic>> getDeviceInfo() async {
    if (Platform.isAndroid) {
      final android = await _deviceInfo.androidInfo;

      return {
        'deviceId': android.id,
        'brand': android.brand,
        'model': android.model,
        'manufacturer': android.manufacturer,
        'androidVersion': android.version.release,
        'sdkInt': android.version.sdkInt,
        'isPhysicalDevice': android.isPhysicalDevice,
      };
    }

    if (Platform.isIOS) {
      final ios = await _deviceInfo.iosInfo;

      return {
        'deviceId': ios.identifierForVendor,
        'deviceName': ios.name,
        'model': ios.model,
        'systemName': ios.systemName,
        'systemVersion': ios.systemVersion,
        'isPhysicalDevice': ios.isPhysicalDevice,
      };
    }

    return {};
  }

  Future<String> getDeviceId() async {
    final info = await getDeviceInfo();

    return info['deviceId']?.toString() ?? '';
  }

  Future<String> getDeviceName() async {
    final info = await getDeviceInfo();

    return info['model']?.toString() ?? '';
  }
}
