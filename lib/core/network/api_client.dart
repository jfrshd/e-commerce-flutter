import 'dart:io';
import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:injectable/injectable.dart';
import '../constants/api_constants.dart';
import '../errors/exceptions.dart';

@LazySingleton()
class ApiClient {
  late final Dio _dio;
  final Connectivity _connectivity = Connectivity();

  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: ApiConstants.defaultHeaders,
    ));

    _dio.interceptors.addAll([
      _AuthInterceptor(),
      _LoggingInterceptor(),
      _ErrorInterceptor(),
    ]);
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    await _checkConnectivity();
    return _dio.get(path, queryParameters: queryParameters, options: options);
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    print('🔗 API Client: Making POST request to $path');
    print('🔗 API Client: Data: $data');
    print('🔗 API Client: Headers: ${options?.headers}');
    await _checkConnectivity();
    try {
      final response = await _dio.post(path,
          data: data, queryParameters: queryParameters, options: options);
      print('✅ API Client: Response status: ${response.statusCode}');
      print('✅ API Client: Response data: ${response.data}');
      return response;
    } catch (e) {
      print('❌ API Client: Error occurred: $e');
      rethrow;
    }
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    await _checkConnectivity();
    return _dio.put(path,
        data: data, queryParameters: queryParameters, options: options);
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    await _checkConnectivity();
    return _dio.delete(path,
        data: data, queryParameters: queryParameters, options: options);
  }

  Future<void> _checkConnectivity() async {
    print('🌐 API Client: Checking connectivity...');
    final connectivityResult = await _connectivity.checkConnectivity();
    print('🌐 API Client: Connectivity result: $connectivityResult');
    if (connectivityResult == ConnectivityResult.none) {
      print('❌ API Client: No internet connection detected');
      throw const NetworkException(message: 'No internet connection');
    }
    print('✅ API Client: Connectivity check passed');
  }
}

class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Add auth token if available
    // This will be implemented when we add token storage
    super.onRequest(options, handler);
  }
}

class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('📤 REQUEST[${options.method}] => PATH: ${options.path}');
    print('📤 Headers: ${options.headers}');
    print('📤 Data: ${options.data}');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print(
        '📥 RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
    print('📥 Data: ${response.data}');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print(
        '❌ ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}');
    print('❌ Message: ${err.message}');
    super.onError(err, handler);
  }
}

class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('🚨 ErrorInterceptor: Handling error - ${err.type}');
    print('🚨 ErrorInterceptor: Error message: ${err.message}');
    print('🚨 ErrorInterceptor: Status code: ${err.response?.statusCode}');
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw const NetworkException(
            message:
                'Request timed out. Please check your internet connection and try again.');
      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode;
        final responseData = err.response?.data;
        String message = 'Something went wrong. Please try again.';

        // Print the full response for debugging
        print('🔍 API Client: Full response data: $responseData');
        print('🔍 API Client: Response status code: $statusCode');

        // Extract user-friendly message from response
        if (responseData is Map<String, dynamic>) {
          final rawMessage = responseData['message'];
          print('🔍 API Client: Raw message: $rawMessage');
          print('🔍 API Client: Raw message type: ${rawMessage.runtimeType}');

          if (rawMessage is String) {
            message = rawMessage;
          } else if (rawMessage is List) {
            // Handle validation errors that come as arrays
            message = rawMessage.join(', ');
          } else {
            message = rawMessage?.toString() ?? message;
          }
          print('🔍 API Client: Extracted error message: $message');
        } else {
          print('🔍 API Client: Response data is not a map: $responseData');
        }

        print('🔍 API Client: Status code: $statusCode, Message: $message');

        if (statusCode == 401) {
          print('🔍 API Client: Throwing AuthException with message: $message');
          // Create a custom DioException with the AuthException as the error
          final authException =
              AuthException(message: message, statusCode: statusCode);
          final customError = DioException(
            requestOptions: err.requestOptions,
            response: err.response,
            type: DioExceptionType.badResponse,
            error: authException,
            message: message,
          );
          throw customError;
        } else if (statusCode == 403) {
          print(
              '🔍 API Client: Throwing ServerException with 403 status code for email verification');
          throw ServerException(message: message, statusCode: statusCode);
        } else if (statusCode == 400) {
          final validationException = ValidationException(message: message);
          final customError = DioException(
            requestOptions: err.requestOptions,
            response: err.response,
            type: DioExceptionType.badResponse,
            error: validationException,
            message: message,
          );
          throw customError;
        } else if (statusCode == 404) {
          throw ServerException(
              message: 'The requested resource was not found',
              statusCode: statusCode);
        } else if (statusCode == 500) {
          throw ServerException(
              message:
                  'Server is temporarily unavailable. Please try again later.',
              statusCode: statusCode);
        } else if (statusCode != null &&
            statusCode >= 400 &&
            statusCode < 500) {
          throw ServerException(message: message, statusCode: statusCode);
        } else {
          throw ServerException(
              message: 'Server error. Please try again later.',
              statusCode: statusCode);
        }
      case DioExceptionType.cancel:
        throw const NetworkException(
            message: 'Request was cancelled. Please try again.');
      case DioExceptionType.connectionError:
        throw const NetworkException(
            message:
                'Unable to connect to the server. Please check your internet connection.');
      case DioExceptionType.badCertificate:
        throw const NetworkException(
            message: 'Security certificate error. Please try again later.');
      case DioExceptionType.unknown:
        if (err.error is SocketException) {
          throw const NetworkException(
              message:
                  'No internet connection. Please check your network and try again.');
        }
        throw const NetworkException(
            message: 'An unexpected error occurred. Please try again.');
    }
  }
}
