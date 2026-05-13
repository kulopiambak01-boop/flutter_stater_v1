class ObdLiveData {
  final double rpm;

  final double speed;

  final double coolantTemp;

  final double batteryVoltage;

  final double engineLoad;

  final double fuelLevel;

  /// NEW
  final double maf;

  final double tripKm;

  final double fuelUsedL;

  final double avgKmL;

  const ObdLiveData({
    required this.rpm,
    required this.speed,
    required this.coolantTemp,
    required this.batteryVoltage,
    required this.engineLoad,
    required this.fuelLevel,

    /// NEW
    required this.maf,
    required this.tripKm,
    required this.fuelUsedL,
    required this.avgKmL,
  });

  factory ObdLiveData.empty() {
    return const ObdLiveData(
      rpm: 0,
      speed: 0,
      coolantTemp: 0,
      batteryVoltage: 0,
      engineLoad: 0,
      fuelLevel: 0,

      /// NEW
      maf: 0,
      tripKm: 0,
      fuelUsedL: 0,
      avgKmL: 0,
    );
  }

  ObdLiveData copyWith({
    double? rpm,
    double? speed,
    double? coolantTemp,
    double? batteryVoltage,
    double? engineLoad,
    double? fuelLevel,

    /// NEW
    double? maf,
    double? tripKm,
    double? fuelUsedL,
    double? avgKmL,
  }) {
    return ObdLiveData(
      rpm: rpm ?? this.rpm,
      speed: speed ?? this.speed,
      coolantTemp: coolantTemp ?? this.coolantTemp,
      batteryVoltage: batteryVoltage ?? this.batteryVoltage,
      engineLoad: engineLoad ?? this.engineLoad,
      fuelLevel: fuelLevel ?? this.fuelLevel,

      /// NEW
      maf: maf ?? this.maf,
      tripKm: tripKm ?? this.tripKm,
      fuelUsedL: fuelUsedL ?? this.fuelUsedL,
      avgKmL: avgKmL ?? this.avgKmL,
    );
  }
}
