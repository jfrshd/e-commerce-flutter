abstract class Failure {
  final String message;

  const Failure({required this.message});
}

class ServerFailure extends Failure {
  final int statusCode;

  const ServerFailure({
    required super.message,
    required this.statusCode,
  });
}

class NetworkFailure extends Failure {
  const NetworkFailure({required super.message});
}

class UnknownFailure extends Failure {
  const UnknownFailure({required super.message});
}
