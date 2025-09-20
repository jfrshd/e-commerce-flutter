import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? profileImage;
  final String? phone;
  final String role;
  final bool isEmailVerified;
  final String language;
  final bool notificationsEnabled;
  final String? location;
  final String theme;
  final DateTime createdAt;

  const UserEntity({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.profileImage,
    this.phone,
    required this.role,
    required this.isEmailVerified,
    required this.language,
    required this.notificationsEnabled,
    this.location,
    required this.theme,
    required this.createdAt,
  });

  String get fullName {
    final first = firstName ?? '';
    final last = lastName ?? '';
    return '$first $last'.trim();
  }

  @override
  List<Object?> get props => [
        id,
        email,
        firstName,
        lastName,
        profileImage,
        phone,
        role,
        isEmailVerified,
        language,
        notificationsEnabled,
        location,
        theme,
        createdAt,
      ];
}
