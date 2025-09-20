part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

class SignupRequested extends AuthEvent {
  final String email;
  final String password;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final bool acceptTerms;

  const SignupRequested({
    required this.email,
    required this.password,
    this.firstName,
    this.lastName,
    this.phone,
    required this.acceptTerms,
  });

  @override
  List<Object?> get props =>
      [email, password, firstName, lastName, phone, acceptTerms];
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

class ProfileRequested extends AuthEvent {
  final String token;

  const ProfileRequested({required this.token});

  @override
  List<Object> get props => [token];
}

class ProfileUpdated extends AuthEvent {
  final String token;
  final Map<String, dynamic> data;

  const ProfileUpdated({
    required this.token,
    required this.data,
  });

  @override
  List<Object> get props => [token, data];
}

class PreferencesUpdated extends AuthEvent {
  final String token;
  final Map<String, dynamic> data;

  const PreferencesUpdated({
    required this.token,
    required this.data,
  });

  @override
  List<Object> get props => [token, data];
}

class PasswordChanged extends AuthEvent {
  final String token;
  final String currentPassword;
  final String newPassword;

  const PasswordChanged({
    required this.token,
    required this.currentPassword,
    required this.newPassword,
  });

  @override
  List<Object> get props => [token, currentPassword, newPassword];
}

class ResetPasswordRequested extends AuthEvent {
  final String code;
  final String password;

  const ResetPasswordRequested({
    required this.code,
    required this.password,
  });

  @override
  List<Object> get props => [code, password];
}

class EmailVerificationRequested extends AuthEvent {
  final String token;

  const EmailVerificationRequested({required this.token});

  @override
  List<Object> get props => [token];
}

class RequestEmailVerificationCodeRequested extends AuthEvent {
  final String email;

  const RequestEmailVerificationCodeRequested({required this.email});

  @override
  List<Object> get props => [email];
}

class VerifyEmailCodeRequested extends AuthEvent {
  final String email;
  final String code;

  const VerifyEmailCodeRequested({
    required this.email,
    required this.code,
  });

  @override
  List<Object> get props => [email, code];
}

class RequestPasswordResetCodeRequested extends AuthEvent {
  final String email;

  const RequestPasswordResetCodeRequested({required this.email});

  @override
  List<Object> get props => [email];
}

class VerifyPasswordResetCodeRequested extends AuthEvent {
  final String email;
  final String code;

  const VerifyPasswordResetCodeRequested({
    required this.email,
    required this.code,
  });

  @override
  List<Object> get props => [email, code];
}

class SetEmailForVerification extends AuthEvent {
  final String email;

  const SetEmailForVerification({required this.email});

  @override
  List<Object> get props => [email];
}

class SetResetCode extends AuthEvent {
  final String email;
  final String code;

  const SetResetCode({required this.email, required this.code});

  @override
  List<Object> get props => [email, code];
}

class DeleteAccountRequested extends AuthEvent {
  final String token;

  const DeleteAccountRequested({required this.token});

  @override
  List<Object> get props => [token];
}
