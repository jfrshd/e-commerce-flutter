class ServerException implements Exception {
  final String message;
  final int? statusCode;

  const ServerException({
    required this.message,
    this.statusCode,
  });

  @override
  String toString() => 'ServerException: $message (Status: $statusCode)';
}

class NetworkException implements Exception {
  final String message;

  const NetworkException({required this.message});

  @override
  String toString() => 'NetworkException: $message';
}

class AuthException implements Exception {
  final String message;
  final int? statusCode;

  const AuthException({
    required this.message,
    this.statusCode,
  });

  @override
  String toString() => 'AuthException: $message (Status: $statusCode)';
}

class ValidationException implements Exception {
  final String message;

  const ValidationException({required this.message});

  @override
  String toString() => 'ValidationException: $message';
}

class EmailVerificationException implements Exception {
  final String message;
  final int? statusCode;

  const EmailVerificationException({
    required this.message,
    this.statusCode,
  });

  @override
  String toString() =>
      'EmailVerificationException: $message (Status: $statusCode)';
}
