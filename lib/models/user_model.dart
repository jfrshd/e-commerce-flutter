import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? profileImage;
  final String? phone;
  final String role;
  final String language;
  final bool notificationsEnabled;
  final String? location;
  final String theme;
  @JsonKey(name: 'createdAt')
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.profileImage,
    this.phone,
    required this.role,
    required this.language,
    required this.notificationsEnabled,
    this.location,
    required this.theme,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  String get fullName {
    final first = firstName ?? '';
    final last = lastName ?? '';
    return '$first $last'.trim();
  }

  String get displayName => fullName.isNotEmpty ? fullName : email;
}
