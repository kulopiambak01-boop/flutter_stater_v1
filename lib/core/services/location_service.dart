import 'package:geolocator/geolocator.dart';

class LocationService {
  Position? _currentPosition;

  Position? get currentPosition => _currentPosition;

  Future<Position> loadCurrentLocation() async {
    final position = await Geolocator.getCurrentPosition();

    _currentPosition = position;

    return position;
  }

  String get locationString {
    if (_currentPosition == null) {
      return '-';
    }

    return '${_currentPosition!.latitude},'
        '${_currentPosition!.longitude}';
  }
}
