import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_shop_app/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_shop_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_shop_app/core/error/failures.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<SignupRequested>(_onSignupRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<ProfileUpdated>(_onProfileUpdated);
    on<PreferencesUpdated>(_onPreferencesUpdated);
    on<PasswordChanged>(_onPasswordChanged);
    on<ResetPasswordRequested>(_onResetPasswordRequested);
    on<EmailVerificationRequested>(_onEmailVerificationRequested);
    on<RequestEmailVerificationCodeRequested>(
        _onRequestEmailVerificationCodeRequested);
    on<VerifyEmailCodeRequested>(_onVerifyEmailCodeRequested);
    on<RequestPasswordResetCodeRequested>(_onRequestPasswordResetCodeRequested);
    on<VerifyPasswordResetCodeRequested>(_onVerifyPasswordResetCodeRequested);
    on<SetEmailForVerification>(_onSetEmailForVerification);
    on<SetResetCode>(_onSetResetCode);
    on<DeleteAccountRequested>(_onDeleteAccountRequested);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    print('🔍 AuthBloc._onLoginRequested: Starting login process');
    print('🔍 AuthBloc._onLoginRequested: Email: ${event.email}');
    print(
        '🔍 AuthBloc._onLoginRequested: Password length: ${event.password.length}');
    emit(AuthLoading());
    try {
      print('🔍 AuthBloc._onLoginRequested: Calling repository login...');
      final user = await authRepository.login(event.email, event.password);
      print(
          '✅ AuthBloc._onLoginRequested: Login successful, user: ${user.email}');
      emit(AuthSuccess(user: user));
    } on Failure catch (failure) {
      print('❌ AuthBloc._onLoginRequested: Login failed - ${failure.message}');
      emit(AuthFailure(failure: failure));
    }
  }

  Future<void> _onSignupRequested(
    SignupRequested event,
    Emitter<AuthState> emit,
  ) async {
    print('🔍 AuthBloc._onSignupRequested: Starting signup process');
    print('🔍 AuthBloc._onSignupRequested: Email: ${event.email}');
    print('🔍 AuthBloc._onSignupRequested: First name: ${event.firstName}');
    print('🔍 AuthBloc._onSignupRequested: Last name: ${event.lastName}');
    print('🔍 AuthBloc._onSignupRequested: Phone: ${event.phone}');
    print('🔍 AuthBloc._onSignupRequested: Accept terms: ${event.acceptTerms}');
    emit(AuthLoading());
    try {
      print('🔍 AuthBloc._onSignupRequested: Calling repository signup...');
      final user = await authRepository.signup(
        email: event.email,
        password: event.password,
        firstName: event.firstName,
        lastName: event.lastName,
        phone: event.phone,
        acceptTerms: event.acceptTerms,
      );
      print(
          '✅ AuthBloc._onSignupRequested: Signup successful, user: ${user.email}');
      emit(AuthSuccess(user: user));
    } on Failure catch (failure) {
      print(
          '❌ AuthBloc._onSignupRequested: Signup failed - ${failure.message}');
      emit(AuthFailure(failure: failure));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await authRepository.logout();
      emit(LogoutSuccess());
    } on Failure catch (failure) {
      emit(AuthFailure(failure: failure));
    }
  }

  Future<void> _onProfileUpdated(
    ProfileUpdated event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.updateProfile(event.token, event.data);
      emit(AuthSuccess(user: user));
    } on Failure catch (failure) {
      emit(AuthFailure(failure: failure));
    }
  }

  Future<void> _onPreferencesUpdated(
    PreferencesUpdated event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user =
          await authRepository.updatePreferences(event.token, event.data);
      emit(AuthSuccess(user: user));
    } on Failure catch (failure) {
      emit(AuthFailure(failure: failure));
    }
  }

  Future<void> _onPasswordChanged(
    PasswordChanged event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await authRepository.changePassword(
        event.token,
        event.currentPassword,
        event.newPassword,
      );
      emit(PasswordChangeSuccess());
    } on Failure catch (failure) {
      emit(AuthFailure(failure: failure));
    }
  }

  Future<void> _onResetPasswordRequested(
    ResetPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await authRepository.resetPassword(event.code, event.password);
      emit(ResetPasswordSuccess());
    } on Failure catch (failure) {
      emit(AuthFailure(failure: failure));
    }
  }

  Future<void> _onEmailVerificationRequested(
    EmailVerificationRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await authRepository.verifyEmail(event.token);
      emit(EmailVerificationSuccess());
    } on Failure catch (failure) {
      emit(AuthFailure(failure: failure));
    }
  }

  Future<void> _onRequestEmailVerificationCodeRequested(
    RequestEmailVerificationCodeRequested event,
    Emitter<AuthState> emit,
  ) async {
    print('🔍 AuthBloc: Request email verification code for: ${event.email}');
    emit(AuthLoading());
    try {
      print('🔍 AuthBloc: Calling repository requestEmailVerificationCode...');
      await authRepository.requestEmailVerificationCode(event.email);
      print('🔍 AuthBloc: Request email verification code successful');
      emit(RequestEmailVerificationCodeSuccess());
    } on Failure catch (failure) {
      print(
          '🔍 AuthBloc: Request email verification code failed: ${failure.message}');
      emit(AuthFailure(failure: failure));
    }
  }

  Future<void> _onVerifyEmailCodeRequested(
    VerifyEmailCodeRequested event,
    Emitter<AuthState> emit,
  ) async {
    print('🔍 AuthBloc: Verify email code requested');
    print('🔍 AuthBloc: Email: ${event.email}');
    print('🔍 AuthBloc: Code: ${event.code}');
    print('🔍 AuthBloc: Code type: ${event.code.runtimeType}');
    print('🔍 AuthBloc: Code length: ${event.code.length}');
    emit(AuthLoading());
    try {
      print('🔍 AuthBloc: Calling repository verifyEmailCode...');
      await authRepository.verifyEmailCode(event.email, event.code);
      print('🔍 AuthBloc: Verify email code successful');
      emit(EmailVerificationSuccess());
    } on Failure catch (failure) {
      print('🔍 AuthBloc: Verify email code failed: ${failure.message}');
      emit(AuthFailure(failure: failure));
    }
  }

  Future<void> _onRequestPasswordResetCodeRequested(
    RequestPasswordResetCodeRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await authRepository.requestPasswordResetCode(event.email);
      emit(RequestPasswordResetCodeSuccess());
    } on Failure catch (failure) {
      emit(AuthFailure(failure: failure));
    }
  }

  Future<void> _onVerifyPasswordResetCodeRequested(
    VerifyPasswordResetCodeRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await authRepository.verifyPasswordResetCode(event.email, event.code);
      emit(ResetPasswordSuccess());
    } on Failure catch (failure) {
      emit(AuthFailure(failure: failure));
    }
  }

  Future<void> _onSetEmailForVerification(
    SetEmailForVerification event,
    Emitter<AuthState> emit,
  ) async {
    print('🔍 AuthBloc._onSetEmailForVerification: Event received');
    print('🔍 AuthBloc._onSetEmailForVerification: Email: ${event.email}');
    print(
        '🔍 AuthBloc._onSetEmailForVerification: Emitting EmailSetForVerification state');
    emit(EmailSetForVerification(email: event.email));
    print('🔍 AuthBloc._onSetEmailForVerification: State emitted successfully');
  }

  Future<void> _onSetResetCode(
    SetResetCode event,
    Emitter<AuthState> emit,
  ) async {
    print('🔍 AuthBloc._onSetResetCode: Event received');
    print('🔍 AuthBloc._onSetResetCode: Email: ${event.email}');
    print('🔍 AuthBloc._onSetResetCode: Code: ${event.code}');
    print('🔍 AuthBloc._onSetResetCode: Emitting ResetCodeSet state');
    emit(ResetCodeSet(email: event.email, code: event.code));
    print('🔍 AuthBloc._onSetResetCode: State emitted successfully');
  }

  Future<void> _onDeleteAccountRequested(
    DeleteAccountRequested event,
    Emitter<AuthState> emit,
  ) async {
    print(
        '🔍 AuthBloc._onDeleteAccountRequested: Starting account deletion process');
    print(
        '🔍 AuthBloc._onDeleteAccountRequested: Token provided: ${event.token.isNotEmpty}');
    emit(AuthLoading());
    try {
      print(
          '🔍 AuthBloc._onDeleteAccountRequested: Calling repository deleteAccount...');
      await authRepository.deleteAccount(event.token);
      print(
          '✅ AuthBloc._onDeleteAccountRequested: Account deletion successful');
      emit(DeleteAccountSuccess());
    } on Failure catch (failure) {
      print(
          '❌ AuthBloc._onDeleteAccountRequested: Account deletion failed - ${failure.message}');
      emit(AuthFailure(failure: failure));
    }
  }
}
