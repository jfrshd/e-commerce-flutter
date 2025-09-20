import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter_shop_app/core/constants/api_constants.dart';
import 'package:flutter_shop_app/core/network/api_client.dart';
import 'package:flutter_shop_app/core/error/exceptions.dart';
import 'package:flutter_shop_app/features/auth/data/models/auth_response_model.dart';
import 'package:flutter_shop_app/features/auth/data/models/signup_response_model.dart';
import 'package:flutter_shop_app/features/auth/data/models/user_model.dart';
import 'package:flutter_shop_app/features/auth/data/models/login_request_model.dart';
import 'package:flutter_shop_app/features/auth/data/models/signup_request_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login(LoginRequestModel request);
  Future<SignupResponseModel> signup(SignupRequestModel request);
  Future<void> resetPassword(String code, String password);
  Future<void> verifyEmail(String token);
  Future<UserModel> getProfile(String token);
  Future<UserModel> updateProfile(String token, Map<String, dynamic> data);
  Future<UserModel> updatePreferences(String token, Map<String, dynamic> data);
  Future<void> changePassword(
      String token, String currentPassword, String newPassword);
  Future<void> requestEmailVerificationCode(String email);
  Future<void> verifyEmailCode(String email, String code);
  Future<void> requestPasswordResetCode(String email);
  Future<void> verifyPasswordResetCode(String email, String code);
  Future<void> deleteAccount(String token);
}

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<AuthResponseModel> login(LoginRequestModel request) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.login,
        data: request.toJson(),
      );
      return AuthResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      print('🔍 AuthRemoteDataSource.login: DioException caught');
      print('🔍 AuthRemoteDataSource.login: Error type: ${e.type}');
      print('🔍 AuthRemoteDataSource.login: Error message: ${e.message}');
      print('🔍 AuthRemoteDataSource.login: Error object: ${e.error}');
      print(
          '🔍 AuthRemoteDataSource.login: Error object type: ${e.error.runtimeType}');
      print(
          '🔍 AuthRemoteDataSource.login: Error object is ServerException: ${e.error is ServerException}');

      // Check if error object has ServerException properties
      print(
          '🔍 AuthRemoteDataSource.login: Checking if error contains ServerException...');
      print(
          '🔍 AuthRemoteDataSource.login: Error toString: ${e.error.toString()}');
      print(
          '🔍 AuthRemoteDataSource.login: Error contains ServerException: ${e.error.toString().contains('ServerException')}');

      if (e.error != null && e.error.toString().contains('ServerException')) {
        print(
            '🔍 AuthRemoteDataSource.login: ServerException detected by string check!');
        // Try to access properties directly
        String? extractedMessage;
        int? extractedStatusCode;

        try {
          final errorObj = e.error as dynamic;
          print(
              '🔍 AuthRemoteDataSource.login: Error object as dynamic: $errorObj');
          print(
              '🔍 AuthRemoteDataSource.login: Error object type: ${errorObj.runtimeType}');

          extractedMessage = errorObj.message as String?;
          extractedStatusCode = errorObj.statusCode as int?;
          print(
              '🔍 AuthRemoteDataSource.login: Extracted message: $extractedMessage');
          print(
              '🔍 AuthRemoteDataSource.login: Extracted statusCode: $extractedStatusCode');
          print(
              '🔍 AuthRemoteDataSource.login: Message is null: ${extractedMessage == null}');
          print(
              '🔍 AuthRemoteDataSource.login: StatusCode is null: ${extractedStatusCode == null}');
        } catch (castError) {
          print(
              '❌ AuthRemoteDataSource.login: Failed to extract ServerException properties: $castError');
          print(
              '❌ AuthRemoteDataSource.login: Cast error type: ${castError.runtimeType}');
        }

        // Re-throw outside the try-catch block
        if (extractedMessage != null && extractedStatusCode != null) {
          print(
              '🔍 AuthRemoteDataSource.login: Both message and statusCode are valid!');
          print(
              '🔍 AuthRemoteDataSource.login: Re-throwing ServerException with statusCode: $extractedStatusCode');
          throw ServerException(
              message: extractedMessage, statusCode: extractedStatusCode);
        } else {
          print(
              '❌ AuthRemoteDataSource.login: Message or statusCode is null, falling through...');
        }
      } else {
        print(
            '🔍 AuthRemoteDataSource.login: Error does not contain ServerException string');
      }

      if (e.error is ServerException) {
        final serverException = e.error as ServerException;
        print('🔍 AuthRemoteDataSource.login: ServerException detected!');
        print(
            '🔍 AuthRemoteDataSource.login: ServerException message: ${serverException.message}');
        print(
            '🔍 AuthRemoteDataSource.login: ServerException statusCode: ${serverException.statusCode}');
        print(
            '🔍 AuthRemoteDataSource.login: Re-throwing ServerException with statusCode: ${serverException.statusCode}');
        throw ServerException(
            message: serverException.message,
            statusCode: serverException.statusCode);
      } else if (e.error is AuthException) {
        final authException = e.error as AuthException;
        print(
            '🔍 AuthRemoteDataSource.login: AuthException - ${authException.message}');
        throw ServerException(
            message: authException.message,
            statusCode: authException.statusCode);
      } else if (e.error is ValidationException) {
        final validationException = e.error as ValidationException;
        print(
            '🔍 AuthRemoteDataSource.login: ValidationException - ${validationException.message}');
        throw ServerException(
            message: validationException.message, statusCode: 400);
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException(message: 'Request timed out. Please try again.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException(
            message: 'No internet connection. Please check your network.');
      } else {
        // Extract message from response if available
        String message = 'Login failed. Please try again.';
        if (e.response?.data is Map<String, dynamic>) {
          final responseData = e.response!.data as Map<String, dynamic>;
          if (responseData['message'] != null) {
            message = responseData['message'].toString();
          }
        }
        throw ServerException(
            message: message, statusCode: e.response?.statusCode ?? 500);
      }
    } catch (e) {
      print('🔍 AuthRemoteDataSource.login: Unknown error - ${e.toString()}');
      if (e is ServerException || e is NetworkException) {
        rethrow;
      }
      throw ServerException(
          message: 'Login failed. Please try again.', statusCode: 500);
    }
  }

  @override
  Future<SignupResponseModel> signup(SignupRequestModel request) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.signup,
        data: request.toJson(),
      );
      return SignupResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      print('🔍 AuthRemoteDataSource.signup: DioException caught');
      print('🔍 AuthRemoteDataSource.signup: Error type: ${e.type}');
      print('🔍 AuthRemoteDataSource.signup: Error message: ${e.message}');
      print('🔍 AuthRemoteDataSource.signup: Error object: ${e.error}');

      if (e.error is AuthException) {
        final authException = e.error as AuthException;
        print(
            '🔍 AuthRemoteDataSource.signup: AuthException - ${authException.message}');
        throw ServerException(
            message: authException.message,
            statusCode: authException.statusCode);
      } else if (e.error is ValidationException) {
        final validationException = e.error as ValidationException;
        print(
            '🔍 AuthRemoteDataSource.signup: ValidationException - ${validationException.message}');
        throw ServerException(
            message: validationException.message, statusCode: 400);
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException(message: 'Request timed out. Please try again.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException(
            message: 'No internet connection. Please check your network.');
      } else {
        // Extract message from response if available
        String message = 'Signup failed. Please try again.';
        if (e.response?.data is Map<String, dynamic>) {
          final responseData = e.response!.data as Map<String, dynamic>;
          if (responseData['message'] != null) {
            message = responseData['message'].toString();
          }
        }
        throw ServerException(
            message: message, statusCode: e.response?.statusCode ?? 500);
      }
    } catch (e) {
      print('🔍 AuthRemoteDataSource.signup: Unknown error - ${e.toString()}');
      if (e is ServerException || e is NetworkException) {
        rethrow;
      }
      throw ServerException(
          message: 'Signup failed. Please try again.', statusCode: 500);
    }
  }

  @override
  Future<void> resetPassword(String code, String password) async {
    await _apiClient.post(
      ApiConstants.resetPassword,
      data: {
        'code': code,
        'password': password,
      },
    );
  }

  @override
  Future<void> verifyEmail(String token) async {
    await _apiClient.post(
      ApiConstants.verifyEmail,
      data: {'token': token},
    );
  }

  @override
  Future<UserModel> getProfile(String token) async {
    final response = await _apiClient.get(
      ApiConstants.profile,
      options: Options(headers: ApiConstants.authHeaders(token)),
    );
    return UserModel.fromJson(response.data);
  }

  @override
  Future<UserModel> updateProfile(
      String token, Map<String, dynamic> data) async {
    final response = await _apiClient.put(
      ApiConstants.profile,
      data: data,
      options: Options(headers: ApiConstants.authHeaders(token)),
    );
    return UserModel.fromJson(response.data);
  }

  @override
  Future<UserModel> updatePreferences(
      String token, Map<String, dynamic> data) async {
    final response = await _apiClient.put(
      ApiConstants.preferences,
      data: data,
      options: Options(headers: ApiConstants.authHeaders(token)),
    );
    return UserModel.fromJson(response.data);
  }

  @override
  Future<void> changePassword(
      String token, String currentPassword, String newPassword) async {
    await _apiClient.put(
      ApiConstants.changePassword,
      data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
      options: Options(headers: ApiConstants.authHeaders(token)),
    );
  }

  @override
  Future<void> requestEmailVerificationCode(String email) async {
    print(
        '🔗 AuthRemoteDataSource: Request email verification code for: $email');
    print(
        '🔗 AuthRemoteDataSource: Making API call to ${ApiConstants.requestEmailCode}');
    try {
      final response = await _apiClient.post(
        ApiConstants.requestEmailCode,
        data: {'email': email},
      );
      print(
          '🔗 AuthRemoteDataSource: API call completed with status: ${response.statusCode}');
      print('🔗 AuthRemoteDataSource: Response data: ${response.data}');
    } on DioException catch (e) {
      print(
          '🔍 AuthRemoteDataSource.requestEmailVerificationCode: DioException caught');
      print(
          '🔍 AuthRemoteDataSource.requestEmailVerificationCode: Error type: ${e.type}');
      print(
          '🔍 AuthRemoteDataSource.requestEmailVerificationCode: Error message: ${e.message}');
      print(
          '🔍 AuthRemoteDataSource.requestEmailVerificationCode: Error object: ${e.error}');

      if (e.error is AuthException) {
        final authException = e.error as AuthException;
        throw ServerException(
            message: authException.message,
            statusCode: authException.statusCode);
      } else if (e.error is ValidationException) {
        final validationException = e.error as ValidationException;
        throw ServerException(
            message: validationException.message, statusCode: 400);
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException(message: 'Request timed out. Please try again.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException(
            message: 'No internet connection. Please check your network.');
      } else {
        String message = 'Failed to send verification code. Please try again.';
        if (e.response?.data is Map<String, dynamic>) {
          final responseData = e.response!.data as Map<String, dynamic>;
          if (responseData['message'] != null) {
            message = responseData['message'].toString();
          }
        }
        throw ServerException(
            message: message, statusCode: e.response?.statusCode ?? 500);
      }
    } catch (e) {
      print(
          '🔍 AuthRemoteDataSource.requestEmailVerificationCode: Unknown error - ${e.toString()}');
      if (e is ServerException || e is NetworkException) {
        rethrow;
      }
      throw ServerException(
          message: 'Failed to send verification code. Please try again.',
          statusCode: 500);
    }
  }

  @override
  Future<void> verifyEmailCode(String email, String code) async {
    print('🔗 AuthRemoteDataSource: Verify email code for: $email');
    print('🔗 AuthRemoteDataSource: Code: $code');
    print('🔗 AuthRemoteDataSource: Code type: ${code.runtimeType}');
    print('🔗 AuthRemoteDataSource: Code length: ${code.length}');
    print(
        '🔗 AuthRemoteDataSource: Making API call to ${ApiConstants.verifyEmailCode}');
    try {
      final response = await _apiClient.post(
        ApiConstants.verifyEmailCode,
        data: {'email': email, 'code': code},
      );
      print(
          '🔗 AuthRemoteDataSource: API call completed with status: ${response.statusCode}');
      print('🔗 AuthRemoteDataSource: Response data: ${response.data}');
    } on DioException catch (e) {
      print('🔍 AuthRemoteDataSource.verifyEmailCode: DioException caught');
      print('🔍 AuthRemoteDataSource.verifyEmailCode: Error type: ${e.type}');
      print(
          '🔍 AuthRemoteDataSource.verifyEmailCode: Error message: ${e.message}');
      print(
          '🔍 AuthRemoteDataSource.verifyEmailCode: Error object: ${e.error}');

      if (e.error is AuthException) {
        final authException = e.error as AuthException;
        throw ServerException(
            message: authException.message,
            statusCode: authException.statusCode);
      } else if (e.error is ValidationException) {
        final validationException = e.error as ValidationException;
        throw ServerException(
            message: validationException.message, statusCode: 400);
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException(message: 'Request timed out. Please try again.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException(
            message: 'No internet connection. Please check your network.');
      } else {
        String message = 'Failed to verify code. Please try again.';
        if (e.response?.data is Map<String, dynamic>) {
          final responseData = e.response!.data as Map<String, dynamic>;
          if (responseData['message'] != null) {
            message = responseData['message'].toString();
          }
        }
        throw ServerException(
            message: message, statusCode: e.response?.statusCode ?? 500);
      }
    } catch (e) {
      print(
          '🔍 AuthRemoteDataSource.verifyEmailCode: Unknown error - ${e.toString()}');
      if (e is ServerException || e is NetworkException) {
        rethrow;
      }
      throw ServerException(
          message: 'Failed to verify code. Please try again.', statusCode: 500);
    }
  }

  @override
  Future<void> requestPasswordResetCode(String email) async {
    await _apiClient.post(
      ApiConstants.requestResetCode,
      data: {'email': email},
    );
  }

  @override
  Future<void> verifyPasswordResetCode(String email, String code) async {
    await _apiClient.post(
      ApiConstants.verifyResetCode,
      data: {'email': email, 'code': code},
    );
  }

  @override
  Future<void> deleteAccount(String token) async {
    try {
      await _apiClient.delete(
        ApiConstants.deleteAccount,
        options: Options(headers: ApiConstants.authHeaders(token)),
      );
    } on DioException catch (e) {
      print('🔍 AuthRemoteDataSource.deleteAccount: DioException caught');
      print('🔍 AuthRemoteDataSource.deleteAccount: Error type: ${e.type}');
      print(
          '🔍 AuthRemoteDataSource.deleteAccount: Error message: ${e.message}');
      print('🔍 AuthRemoteDataSource.deleteAccount: Error object: ${e.error}');

      if (e.error is AuthException) {
        final authException = e.error as AuthException;
        throw ServerException(
            message: authException.message,
            statusCode: authException.statusCode);
      } else if (e.error is ValidationException) {
        final validationException = e.error as ValidationException;
        throw ServerException(
            message: validationException.message, statusCode: 400);
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException(message: 'Request timed out. Please try again.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException(
            message: 'No internet connection. Please check your network.');
      } else {
        String message = 'Failed to delete account. Please try again.';
        if (e.response?.data is Map<String, dynamic>) {
          final responseData = e.response!.data as Map<String, dynamic>;
          if (responseData['message'] != null) {
            message = responseData['message'].toString();
          }
        }
        throw ServerException(
            message: message, statusCode: e.response?.statusCode ?? 500);
      }
    } catch (e) {
      print(
          '🔍 AuthRemoteDataSource.deleteAccount: Unknown error - ${e.toString()}');
      if (e is ServerException || e is NetworkException) {
        rethrow;
      }
      throw ServerException(
          message: 'Failed to delete account. Please try again.',
          statusCode: 500);
    }
  }
}
