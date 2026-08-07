abstract class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException(super.message);
}

class TimeoutAppException extends AppException {
  const TimeoutAppException(super.message);
}

class AuthException extends AppException {
  const AuthException(super.message);
}

class ServerException extends AppException {
  const ServerException(super.message);
}

class ApiException extends AppException {
  const ApiException(super.message);
}
