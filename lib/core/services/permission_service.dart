import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  /// generic request permission
  Future<bool> request(Permission permission) async {
    final status = await permission.request();

    return status.isGranted;
  }

  /// check current permission status
  Future<PermissionStatus> status(Permission permission) async {
    return permission.status;
  }

  /// open app setting
  Future<bool> openSettings() async {
    return openAppSettings();
  }

  /// camera permission
  Future<bool> camera() async {
    return request(Permission.camera);
  }

  /// storage permission
  Future<bool> storage() async {
    return request(Permission.storage);
  }

  Future<bool> bluetoothScan() => request(Permission.bluetoothScan);

  Future<bool> bluetoothConnect() => request(Permission.bluetoothConnect);

  Future<bool> nearbyWifiDevices() => request(Permission.nearbyWifiDevices);

  /// location permission only
  Future<bool> location() async {
    final status = await Permission.location.request();

    return status.isGranted;
  }

  /// validate full location flow
  Future<bool> handleLocationPermission() async {
    /// gps aktif?
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw Exception('Location service disabled');
    }

    /// cek permission
    var status = await Permission.location.status;

    /// request jika denied
    if (status.isDenied) {
      status = await Permission.location.request();
    }

    /// masih denied
    if (status.isDenied) {
      throw Exception('Location permission denied');
    }

    /// permanently denied
    if (status.isPermanentlyDenied) {
      throw Exception('Location permission permanently denied');
    }

    return true;
  }
}
