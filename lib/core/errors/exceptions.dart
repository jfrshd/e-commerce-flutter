class ServerException implements Exception {
  final String message;
  final int? statusCode;

  const ServerException({
    required this.message,
    this.statusCode,
  });
}

class NetworkException implements Exception {
  final String message;

  const NetworkException({
    required this.message,
  });
}

class CacheException implements Exception {
  final String message;

  const CacheException({
    required this.message,
  });
}

class ValidationException implements Exception {
  final String message;

  const ValidationException({
    required this.message,
  });
}

class AuthException implements Exception {
  final String message;
  final int? statusCode;

  const AuthException({
    required this.message,
    this.statusCode,
  });
}
