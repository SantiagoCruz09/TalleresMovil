abstract class TaskException implements Exception {
  final String message;
  final dynamic originalException;

  TaskException({
    required this.message,
     this.originalException,
  });

  @override
  String toString() => message;
}

class NetworkException extends TaskException {
  NetworkException({
    required super.message,
     super.originalException,
  });
}

class TimeoutException extends TaskException {
  TimeoutException({
    required super.message,
     super.originalException,
  });
}

class SyncException extends TaskException {
  final int? statusCode;

  SyncException({
    required super.message,
     super.originalException,
    this.statusCode,
  });
}

class DatabaseException extends TaskException {
  DatabaseException({
    required super.message,
     super.originalException,
  });
}

class ValidationException extends TaskException {
  ValidationException({
    required super.message,
     super.originalException,
  });
}
