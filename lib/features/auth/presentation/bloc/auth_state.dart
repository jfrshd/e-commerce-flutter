part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final UserEntity user;

  const AuthSuccess({required this.user});

  @override
  List<Object> get props => [user];
}

class AuthFailure extends AuthState {
  final Failure failure;

  const AuthFailure({required this.failure});

  @override
  List<Object> get props => [failure];
}

class PasswordChangeSuccess extends AuthState {}

class ResetPasswordSuccess extends AuthState {}

class EmailVerificationSuccess extends AuthState {}

class LogoutSuccess extends AuthState {}

class RequestEmailVerificationCodeSuccess extends AuthState {}

class RequestPasswordResetCodeSuccess extends AuthState {}

class EmailSetForVerification extends AuthState {
  final String email;

  const EmailSetForVerification({required this.email});

  @override
  List<Object> get props => [email];
}

class ResetCodeSet extends AuthState {
  final String email;
  final String code;

  const ResetCodeSet({required this.email, required this.code});

  @override
  List<Object> get props => [email, code];
}

class DeleteAccountSuccess extends AuthState {}
