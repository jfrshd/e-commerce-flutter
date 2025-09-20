import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

class AuthSignupRequested extends AuthEvent {
  final String email;
  final String password;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final bool acceptTerms;

  const AuthSignupRequested({
    required this.email,
    required this.password,
    this.firstName,
    this.lastName,
    this.phone,
    required this.acceptTerms,
  });

  @override
  List<Object?> get props => [email, password, firstName, lastName, phone, acceptTerms];
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

class AuthStatusChecked extends AuthEvent {
  const AuthStatusChecked();
}

class AuthProfileUpdated extends AuthEvent {
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? profileImage;

  const AuthProfileUpdated({
    this.firstName,
    this.lastName,
    this.phone,
    this.profileImage,
  });

  @override
  List<Object?> get props => [firstName, lastName, phone, profileImage];
}

class AuthPreferencesUpdated extends AuthEvent {
  final String? language;
  final bool? notificationsEnabled;
  final String? location;
  final String? theme;

  const AuthPreferencesUpdated({
    this.language,
    this.notificationsEnabled,
    this.location,
    this.theme,
  });

  @override
  List<Object?> get props => [language, notificationsEnabled, location, theme];
}

class AuthPasswordChanged extends AuthEvent {
  final String currentPassword;
  final String newPassword;

  const AuthPasswordChanged({
    required this.currentPassword,
    required this.newPassword,
  });

  @override
  List<Object> get props => [currentPassword, newPassword];
}
