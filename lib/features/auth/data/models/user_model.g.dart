// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      id: json['id'] as String?,
      email: json['email'] as String,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      profileImage: json['profileImage'] as String?,
      phone: _phoneFromJson(json['phone']),
      role: json['role'] as String?,
      isEmailVerified: json['isEmailVerified'] as bool?,
      language: json['language'] as String?,
      notificationsEnabled: json['notificationsEnabled'] as bool?,
      location: json['location'] as String?,
      theme: json['theme'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'profileImage': instance.profileImage,
      'phone': _phoneToJson(instance.phone),
      'role': instance.role,
      'isEmailVerified': instance.isEmailVerified,
      'language': instance.language,
      'notificationsEnabled': instance.notificationsEnabled,
      'location': instance.location,
      'theme': instance.theme,
      'createdAt': instance.createdAt?.toIso8601String(),
    };
