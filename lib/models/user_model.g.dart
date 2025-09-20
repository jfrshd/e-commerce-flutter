// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      profileImage: json['profileImage'] as String?,
      phone: json['phone'] as String?,
      role: json['role'] as String,
      language: json['language'] as String,
      notificationsEnabled: json['notificationsEnabled'] as bool,
      location: json['location'] as String?,
      theme: json['theme'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'profileImage': instance.profileImage,
      'phone': instance.phone,
      'role': instance.role,
      'language': instance.language,
      'notificationsEnabled': instance.notificationsEnabled,
      'location': instance.location,
      'theme': instance.theme,
      'createdAt': instance.createdAt.toIso8601String(),
    };
