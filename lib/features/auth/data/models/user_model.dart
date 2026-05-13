import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/user.dart';

@JsonSerializable()
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.deviceInfo,
    required super.androidVersion,
    required super.sdkInt,
    required super.location,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'].toString(),
      email: json['email'] as String,
      deviceInfo: json['deviceInfo'] as String,
      androidVersion: json['androidVersion'] as String,
      sdkInt: (json['sdkInt'] as num).toInt(),
      location: json['location'] as String,
    );
  }
}
