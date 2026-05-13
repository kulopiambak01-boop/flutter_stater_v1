class User {
  final String id;
  final String email;
  final String deviceInfo;
  final String androidVersion;
  final int sdkInt;
  final String location;

  const User({
    required this.id,
    required this.email,
    required this.deviceInfo,
    required this.androidVersion,
    required this.sdkInt,
    required this.location,
  });
}
