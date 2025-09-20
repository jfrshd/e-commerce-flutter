import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user_entity.dart';

part 'user_model.g.dart';

// Helper functions for phone conversion
String? _phoneFromJson(dynamic phone) {
  if (phone == null) return null;
  return phone.toString();
}

dynamic _phoneToJson(String? phone) => phone;

@JsonSerializable()
class UserModel {
  final String? id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? profileImage;
  @JsonKey(fromJson: _phoneFromJson, toJson: _phoneToJson)
  final String? phone;
  final String? role;
  final bool? isEmailVerified;
  final String? language;
  final bool? notificationsEnabled;
  final String? location;
  final String? theme;
  final DateTime? createdAt;

  const UserModel({
    this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.profileImage,
    this.phone,
    this.role,
    this.isEmailVerified,
    this.language,
    this.notificationsEnabled,
    this.location,
    this.theme,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    print('🔄 UserModel: Parsing JSON: $json');
    print('🔄 UserModel: ID: ${json['id']} (${json['id'].runtimeType})');
    print(
        '🔄 UserModel: Email: ${json['email']} (${json['email'].runtimeType})');
    print(
        '🔄 UserModel: FirstName: ${json['firstName']} (${json['firstName'].runtimeType})');
    print(
        '🔄 UserModel: LastName: ${json['lastName']} (${json['lastName'].runtimeType})');
    print(
        '🔄 UserModel: ProfileImage: ${json['profileImage']} (${json['profileImage'].runtimeType})');
    print(
        '🔄 UserModel: Phone: ${json['phone']} (${json['phone'].runtimeType})');
    print('🔄 UserModel: Role: ${json['role']} (${json['role'].runtimeType})');
    print(
        '🔄 UserModel: Language: ${json['language']} (${json['language'].runtimeType})');
    print(
        '🔄 UserModel: NotificationsEnabled: ${json['notificationsEnabled']} (${json['notificationsEnabled'].runtimeType})');
    print(
        '🔄 UserModel: Location: ${json['location']} (${json['location'].runtimeType})');
    print(
        '🔄 UserModel: Theme: ${json['theme']} (${json['theme'].runtimeType})');
    print(
        '🔄 UserModel: CreatedAt: ${json['createdAt']} (${json['createdAt'].runtimeType})');

    try {
      print('🔄 UserModel: About to parse...');
      final model = _$UserModelFromJson(json);
      print('🔄 UserModel: Parsed successfully!');
      return model;
    } catch (e, stackTrace) {
      print('❌ UserModel: Error during parsing: $e');
      print('❌ UserModel: Stack trace: $stackTrace');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  String get fullName {
    final first = firstName ?? '';
    final last = lastName ?? '';
    return '$first $last'.trim();
  }

  UserEntity toEntity() {
    print('🔄 UserModel: Converting to UserEntity for email: $email');
    final entity = UserEntity(
      id: id ?? 'unknown_id',
      email: email,
      firstName: firstName,
      lastName: lastName,
      profileImage: profileImage,
      phone: phone,
      role: role ?? 'user', // Default to 'user' if null
      isEmailVerified: isEmailVerified ?? false, // Default to false if null
      language: language ?? 'en', // Default to 'en' if null
      notificationsEnabled:
          notificationsEnabled ?? true, // Default to true if null
      location: location,
      theme: theme ?? 'light', // Default to 'light' if null
      createdAt: createdAt ?? DateTime.now(),
    );
    print('🔄 UserModel: Conversion completed successfully');
    return entity;
  }
}
