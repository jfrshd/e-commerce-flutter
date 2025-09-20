import 'package:injectable/injectable.dart';
import 'package:flutter_shop_app/core/error/exceptions.dart';
import 'package:flutter_shop_app/core/error/failures.dart';
import 'package:flutter_shop_app/core/network/network_info.dart';
import 'package:flutter_shop_app/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:flutter_shop_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:flutter_shop_app/features/auth/data/models/signup_request_model.dart';
import 'package:flutter_shop_app/features/auth/data/models/login_request_model.dart';
import 'package:flutter_shop_app/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_shop_app/features/auth/domain/repositories/auth_repository.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
    required NetworkInfo networkInfo,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        _networkInfo = networkInfo;

  @override
  Future<UserEntity> login(String email, String password) async {
    print('🔍 AuthRepository.login: Starting login process');
    print('🔍 AuthRepository.login: Email: $email');
    print('🔍 AuthRepository.login: Password length: ${password.length}');

    if (await _networkInfo.isConnected) {
      print(
          '🔍 AuthRepository.login: Network connected, calling remote data source');
      try {
        final authResponse = await _remoteDataSource.login(
          LoginRequestModel(email: email, password: password),
        );
        print(
            '🔍 AuthRepository.login: Remote call successful, caching response');
        await _localDataSource.cacheAuthResponse(authResponse);
        print('✅ AuthRepository.login: Login successful');
        return await authResponse.user.toEntity();
      } on ServerException catch (e) {
        print('❌ AuthRepository.login: ServerException caught!');
        print('❌ AuthRepository.login: Server error message - ${e.message}');
        print(
            '❌ AuthRepository.login: Server error statusCode - ${e.statusCode}');
        print(
            '❌ AuthRepository.login: Server error statusCode is null - ${e.statusCode == null}');
        print(
            '❌ AuthRepository.login: Server error statusCode type - ${e.statusCode.runtimeType}');
        print(
            '❌ AuthRepository.login: Converting to ServerFailure with statusCode: ${e.statusCode ?? 500}');
        print('❌ AuthRepository.login: About to throw ServerFailure...');
        throw ServerFailure(
            message: e.message, statusCode: e.statusCode ?? 500);
      } on NetworkException catch (e) {
        print('❌ AuthRepository.login: Network error - ${e.message}');
        throw NetworkFailure(message: e.message);
      } catch (e) {
        print('❌ AuthRepository.login: Unknown error - ${e.toString()}');
        throw UnknownFailure(message: e.toString());
      }
    } else {
      print('❌ AuthRepository.login: No internet connection');
      throw NetworkFailure(message: 'No internet connection');
    }
  }

  @override
  Future<UserEntity> signup({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
    String? phone,
    required bool acceptTerms,
  }) async {
    print('🔍 AuthRepository.signup: Starting signup process');
    print('🔍 AuthRepository.signup: Email: $email');
    print('🔍 AuthRepository.signup: First name: $firstName');
    print('🔍 AuthRepository.signup: Last name: $lastName');
    print('🔍 AuthRepository.signup: Phone: $phone');
    print('🔍 AuthRepository.signup: Accept terms: $acceptTerms');

    if (await _networkInfo.isConnected) {
      print(
          '🔍 AuthRepository.signup: Network connected, calling remote data source');
      try {
        final signupResponse = await _remoteDataSource.signup(
          SignupRequestModel(
            email: email,
            password: password,
            firstName: firstName,
            lastName: lastName,
            phone: phone,
            acceptTerms: acceptTerms,
          ),
        );
        print(
            '🔍 AuthRepository.signup: Remote call successful, signup response received');
        print('🔍 AuthRepository.signup: Message: ${signupResponse.message}');
        print('🔍 AuthRepository.signup: User ID: ${signupResponse.userId}');
        print('🔍 AuthRepository.signup: Email: ${signupResponse.email}');

        // Create a minimal user entity for signup response
        // Since we don't have full user data, we'll create a basic entity
        final userEntity = UserEntity(
          id: signupResponse.userId,
          email: signupResponse.email,
          firstName: firstName ?? '',
          lastName: lastName ?? '',
          phone: phone ?? '',
          role: 'user', // Default role for new users
          isEmailVerified: false, // Signup requires email verification
          language: 'en', // Default language
          notificationsEnabled: true, // Default notification setting
          theme: 'light', // Default theme
          createdAt: DateTime.now(), // Current time as creation time
        );

        print('✅ AuthRepository.signup: Signup successful');
        return userEntity;
      } on ServerException catch (e) {
        print('❌ AuthRepository.signup: Server error - ${e.message}');
        throw ServerFailure(
            message: e.message, statusCode: e.statusCode ?? 500);
      } on NetworkException catch (e) {
        print('❌ AuthRepository.signup: Network error - ${e.message}');
        throw NetworkFailure(message: e.message);
      } catch (e) {
        print('❌ AuthRepository.signup: Unknown error - ${e.toString()}');
        throw UnknownFailure(message: e.toString());
      }
    } else {
      print('❌ AuthRepository.signup: No internet connection');
      throw NetworkFailure(message: 'No internet connection');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _localDataSource.clearAuthData();
    } catch (e) {
      throw UnknownFailure(message: e.toString());
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    try {
      final token = await _localDataSource.getToken();
      return token != null;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      final token = await _localDataSource.getToken();
      if (token != null) {
        return await getProfile(token);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> resetPassword(String code, String password) async {
    if (await _networkInfo.isConnected) {
      try {
        await _remoteDataSource.resetPassword(code, password);
      } on ServerException catch (e) {
        throw ServerFailure(
            message: e.message, statusCode: e.statusCode ?? 500);
      } on NetworkException catch (e) {
        throw NetworkFailure(message: e.message);
      } catch (e) {
        throw UnknownFailure(message: e.toString());
      }
    } else {
      throw NetworkFailure(message: 'No internet connection');
    }
  }

  @override
  Future<void> verifyEmail(String token) async {
    if (await _networkInfo.isConnected) {
      try {
        await _remoteDataSource.verifyEmail(token);
      } on ServerException catch (e) {
        throw ServerFailure(
            message: e.message, statusCode: e.statusCode ?? 500);
      } on NetworkException catch (e) {
        throw NetworkFailure(message: e.message);
      } catch (e) {
        throw UnknownFailure(message: e.toString());
      }
    } else {
      throw NetworkFailure(message: 'No internet connection');
    }
  }

  @override
  Future<UserEntity> getProfile(String token) async {
    if (await _networkInfo.isConnected) {
      try {
        final user = await _remoteDataSource.getProfile(token);
        return user.toEntity();
      } on ServerException catch (e) {
        throw ServerFailure(
            message: e.message, statusCode: e.statusCode ?? 500);
      } on NetworkException catch (e) {
        throw NetworkFailure(message: e.message);
      } catch (e) {
        throw UnknownFailure(message: e.toString());
      }
    } else {
      throw NetworkFailure(message: 'No internet connection');
    }
  }

  @override
  Future<UserEntity> updateProfile(
      String token, Map<String, dynamic> data) async {
    if (await _networkInfo.isConnected) {
      try {
        final user = await _remoteDataSource.updateProfile(token, data);
        return user.toEntity();
      } on ServerException catch (e) {
        throw ServerFailure(
            message: e.message, statusCode: e.statusCode ?? 500);
      } on NetworkException catch (e) {
        throw NetworkFailure(message: e.message);
      } catch (e) {
        throw UnknownFailure(message: e.toString());
      }
    } else {
      throw NetworkFailure(message: 'No internet connection');
    }
  }

  @override
  Future<UserEntity> updatePreferences(
      String token, Map<String, dynamic> data) async {
    if (await _networkInfo.isConnected) {
      try {
        final user = await _remoteDataSource.updatePreferences(token, data);
        return user.toEntity();
      } on ServerException catch (e) {
        throw ServerFailure(
            message: e.message, statusCode: e.statusCode ?? 500);
      } on NetworkException catch (e) {
        throw NetworkFailure(message: e.message);
      } catch (e) {
        throw UnknownFailure(message: e.toString());
      }
    } else {
      throw NetworkFailure(message: 'No internet connection');
    }
  }

  @override
  Future<void> changePassword(
      String token, String currentPassword, String newPassword) async {
    if (await _networkInfo.isConnected) {
      try {
        await _remoteDataSource.changePassword(
            token, currentPassword, newPassword);
      } on ServerException catch (e) {
        throw ServerFailure(
            message: e.message, statusCode: e.statusCode ?? 500);
      } on NetworkException catch (e) {
        throw NetworkFailure(message: e.message);
      } catch (e) {
        throw UnknownFailure(message: e.toString());
      }
    } else {
      throw NetworkFailure(message: 'No internet connection');
    }
  }

  @override
  Future<void> requestEmailVerificationCode(String email) async {
    print('🔍 AuthRepository: Request email verification code for: $email');
    if (await _networkInfo.isConnected) {
      try {
        print('🔍 AuthRepository: Calling remote data source...');
        await _remoteDataSource.requestEmailVerificationCode(email);
        print('🔍 AuthRepository: Request email verification code successful');
      } on ServerException catch (e) {
        print(
            '🔍 AuthRepository: Request email verification code failed - ServerException: ${e.message}');
        throw ServerFailure(
            message: e.message, statusCode: e.statusCode ?? 500);
      } on NetworkException catch (e) {
        print(
            '🔍 AuthRepository: Request email verification code failed - NetworkException: ${e.message}');
        throw NetworkFailure(message: e.message);
      } catch (e) {
        print(
            '🔍 AuthRepository: Request email verification code failed - Unknown error: ${e.toString()}');
        throw UnknownFailure(message: e.toString());
      }
    } else {
      print('🔍 AuthRepository: No internet connection');
      throw NetworkFailure(message: 'No internet connection');
    }
  }

  @override
  Future<void> verifyEmailCode(String email, String code) async {
    print('🔍 AuthRepository: Verify email code for: $email');
    print('🔍 AuthRepository: Code: $code');
    print('🔍 AuthRepository: Code type: ${code.runtimeType}');
    print('🔍 AuthRepository: Code length: ${code.length}');
    if (await _networkInfo.isConnected) {
      try {
        print('🔍 AuthRepository: Calling remote data source...');
        await _remoteDataSource.verifyEmailCode(email, code);
        print('🔍 AuthRepository: Verify email code successful');
      } on ServerException catch (e) {
        print(
            '🔍 AuthRepository: Verify email code failed - ServerException: ${e.message}');
        throw ServerFailure(
            message: e.message, statusCode: e.statusCode ?? 500);
      } on NetworkException catch (e) {
        print(
            '🔍 AuthRepository: Verify email code failed - NetworkException: ${e.message}');
        throw NetworkFailure(message: e.message);
      } catch (e) {
        print(
            '🔍 AuthRepository: Verify email code failed - Unknown error: ${e.toString()}');
        throw UnknownFailure(message: e.toString());
      }
    } else {
      print('🔍 AuthRepository: No internet connection');
      throw NetworkFailure(message: 'No internet connection');
    }
  }

  @override
  Future<void> requestPasswordResetCode(String email) async {
    if (await _networkInfo.isConnected) {
      try {
        await _remoteDataSource.requestPasswordResetCode(email);
      } on ServerException catch (e) {
        throw ServerFailure(
            message: e.message, statusCode: e.statusCode ?? 500);
      } on NetworkException catch (e) {
        throw NetworkFailure(message: e.message);
      } catch (e) {
        throw UnknownFailure(message: e.toString());
      }
    } else {
      throw NetworkFailure(message: 'No internet connection');
    }
  }

  @override
  Future<void> verifyPasswordResetCode(String email, String code) async {
    if (await _networkInfo.isConnected) {
      try {
        await _remoteDataSource.verifyPasswordResetCode(email, code);
      } on ServerException catch (e) {
        throw ServerFailure(
            message: e.message, statusCode: e.statusCode ?? 500);
      } on NetworkException catch (e) {
        throw NetworkFailure(message: e.message);
      } catch (e) {
        throw UnknownFailure(message: e.toString());
      }
    } else {
      throw NetworkFailure(message: 'No internet connection');
    }
  }

  @override
  Future<void> deleteAccount(String token) async {
    print('🔍 AuthRepository.deleteAccount: Starting account deletion process');
    print(
        '🔍 AuthRepository.deleteAccount: Token provided: ${token.isNotEmpty}');

    if (await _networkInfo.isConnected) {
      try {
        print(
            '🔍 AuthRepository.deleteAccount: Network connected, calling remote data source');
        await _remoteDataSource.deleteAccount(token);
        print(
            '🔍 AuthRepository.deleteAccount: Remote call successful, clearing local data');
        await _localDataSource.clearAuthData();
        print('✅ AuthRepository.deleteAccount: Account deletion successful');
      } on ServerException catch (e) {
        print('❌ AuthRepository.deleteAccount: Server error - ${e.message}');
        throw ServerFailure(
            message: e.message, statusCode: e.statusCode ?? 500);
      } on NetworkException catch (e) {
        print('❌ AuthRepository.deleteAccount: Network error - ${e.message}');
        throw NetworkFailure(message: e.message);
      } catch (e) {
        print(
            '❌ AuthRepository.deleteAccount: Unknown error - ${e.toString()}');
        throw UnknownFailure(message: e.toString());
      }
    } else {
      print('❌ AuthRepository.deleteAccount: No internet connection');
      throw NetworkFailure(message: 'No internet connection');
    }
  }
}
