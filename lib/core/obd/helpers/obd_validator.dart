import '../protocol/obd_limit.dart';

class ObdValidator {
  static bool rpm(double v) {
    return v >= 0 && v <= ObdLimit.maxRpm;
  }

  static bool speed(double v) {
    return v >= 0 && v <= ObdLimit.maxSpeed;
  }

  static bool coolant(double v) {
    return v >= ObdLimit.minCoolant && v <= ObdLimit.maxCoolant;
  }

  static bool battery(double v) {
    return v >= ObdLimit.minBattery && v <= ObdLimit.maxBattery;
  }

  static bool percentage(double v) {
    return v >= 0 && v <= 100;
  }
}
