import '../models/obd_capability.dart';

class ObdCapabilityService {
  Future<ObdCapability> detect({
    required Future<String> Function(String cmd) send,
  }) async {
    final rpm = await send('010C');

    final speed = await send('010D');

    final coolant = await send('0105');

    final fuel = await send('012F');

    final battery = await send('0142');

    final engineLoad = await send('0104');

    bool supported(String raw) {
      return !raw.toUpperCase().contains('NO DATA');
    }

    return ObdCapability(
      rpm: supported(rpm),
      speed: supported(speed),
      coolant: supported(coolant),
      fuel: supported(fuel),
      battery: supported(battery),
      engineLoad: supported(engineLoad),
    );
  }
}
