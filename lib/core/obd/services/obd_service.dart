import '../models/obd_device.dart';

abstract class ObdService {
  /// CONNECTION
  Future<void> connect();

  Future<void> disconnect();

  Future<bool> isConnected();

  /// DEVICE SCAN
  Future<List<ObdDevice>> scan();

  /// RAW COMMAND
  Future<String> sendCommand(String command);
}
