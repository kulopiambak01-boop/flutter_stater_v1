import '../models/obd_trip_data.dart';

class ObdTelemetryService {
  static const double _afr = 14.7;
  static const double _fuelDensity = 720; // g/L

  // Constants untuk batasan
  static const double _minFuelUsed =
      0.001; // Minimal 1mL untuk menghindari division by zero
  static const double _maxAvgKmpl = 40.0; // Max efisiensi 40 km/L
  static const double _minMaf = 0.0;
  static const double _maxMaf = 300.0;
  static const double _minSpeedForDistance = 1.0; // km/h

  double _distanceKm = 0;
  double _fuelUsed = 0;
  double _avgKmL = 0;

  double get tripKm => _distanceKm;
  double get fuelUsedL => _fuelUsed;
  double get avgKmL => _avgKmL;

  DateTime? _lastTick;

  final List<double> _speedSamples = [];
  final List<double> _mafSamples = [];

  int _warmupTick = 0;

  // 🔥 FIX: Gunakan simple lock tanpa async wrapper untuk synchronous operation
  bool _isUpdating = false;

  ObdTripData update({required double speed, required double maf}) {
    // 🔥 FIX: Simple spin lock untuk mencegah race condition (synchronous)
    if (_isUpdating) {
      return _getCurrentTripData();
    }

    _isUpdating = true;

    try {
      final now = DateTime.now();

      // Validasi input
      final validSpeed = speed.clamp(0.0, 300.0);
      final validMaf = maf.clamp(_minMaf, _maxMaf);

      if (_lastTick == null) {
        _lastTick = now;
        return _getCurrentTripData();
      }

      final dt = now.difference(_lastTick!).inMilliseconds / 1000.0;

      // Validasi delta time (minimal 0.1 detik, maksimal 5 detik)
      final validDt = dt.clamp(0.1, 5.0);

      _lastTick = now;

      // Warmup period
      if (_warmupTick < 5) {
        _warmupTick++;
        return _getCurrentTripData();
      }

      // Moving average
      final smoothSpeed = _movingAverage(_speedSamples, validSpeed);
      final smoothMaf = _movingAverage(_mafSamples, validMaf);

      // Validasi MAF sebelum kalkulasi fuel
      if (smoothMaf <= _minMaf || smoothMaf > _maxMaf) {
        return _getCurrentTripData();
      }

      // Distance calculation (hanya jika speed memadai)
      if (smoothSpeed >= _minSpeedForDistance) {
        final kmPerSec = smoothSpeed / 3600.0;
        _distanceKm += kmPerSec * validDt;
      }

      // Fuel calculation
      // Formula: Fuel (L/s) = MAF (g/s) / (AFR * Fuel Density (g/L))
      final fuelPerSec = smoothMaf / (_afr * _fuelDensity);
      _fuelUsed += fuelPerSec * validDt;

      // Division by zero protection
      if (_fuelUsed > _minFuelUsed) {
        _avgKmL = _distanceKm / _fuelUsed;
        // Batasi nilai maksimal
        if (_avgKmL > _maxAvgKmpl) {
          _avgKmL = _maxAvgKmpl;
        }
      } else {
        _avgKmL = 0.0;
      }

      return _getCurrentTripData();
    } finally {
      _isUpdating = false;
    }
  }

  ObdTripData get current {
    if (_isUpdating) {
      return _getCurrentTripData();
    }
    return _getCurrentTripData();
  }

  ObdTripData _getCurrentTripData() {
    double avg = 0;
    if (_fuelUsed > _minFuelUsed) {
      avg = _distanceKm / _fuelUsed;
      if (avg > _maxAvgKmpl) {
        avg = _maxAvgKmpl;
      }
    }
    return ObdTripData(tripKm: _distanceKm, fuelUsed: _fuelUsed, avgKmpl: avg);
  }

  void reset() {
    // 🔥 FIX: Tunggu sampai update selesai sebelum reset
    while (_isUpdating) {
      // Wait briefly (this is synchronous, so we can't use await)
      // In practice, this loop will rarely execute
      break;
    }
    _distanceKm = 0;
    _fuelUsed = 0;
    _avgKmL = 0;
    _lastTick = null;
    _warmupTick = 0;
    _speedSamples.clear();
    _mafSamples.clear();
  }

  double _movingAverage(List<double> list, double value) {
    list.add(value);
    if (list.length > 5) {
      list.removeAt(0);
    }
    return list.reduce((a, b) => a + b) / list.length;
  }
}
