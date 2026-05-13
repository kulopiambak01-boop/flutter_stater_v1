class ObdTripData {
  final double tripKm;

  final double fuelUsed;

  final double avgKmpl;

  const ObdTripData({
    required this.tripKm,
    required this.fuelUsed,
    required this.avgKmpl,
  });

  factory ObdTripData.empty() {
    return const ObdTripData(tripKm: 0, fuelUsed: 0, avgKmpl: 0);
  }

  ObdTripData copyWith({double? tripKm, double? fuelUsed, double? avgKmpl}) {
    return ObdTripData(
      tripKm: tripKm ?? this.tripKm,
      fuelUsed: fuelUsed ?? this.fuelUsed,
      avgKmpl: avgKmpl ?? this.avgKmpl,
    );
  }
}
