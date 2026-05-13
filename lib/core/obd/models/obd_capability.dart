class ObdCapability {
  final bool rpm;

  final bool speed;

  final bool coolant;

  final bool fuel;

  final bool battery;

  final bool engineLoad;

  const ObdCapability({
    required this.rpm,
    required this.speed,
    required this.coolant,
    required this.fuel,
    required this.battery,
    required this.engineLoad,
  });
}
