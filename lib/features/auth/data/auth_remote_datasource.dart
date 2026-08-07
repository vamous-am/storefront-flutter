import '../../../core/network/api_client.dart';
import '../../../core/errors/exceptions.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<String> login(String username, String password) async {
    final data = await _apiClient.postJson('/auth/login', {
      'username': username,
      'password': password,
    });

    final token = data['token'] as String?;
    if (token == null) {
      throw const AuthException('Failed to retrieve authentication token.');
    }
    return token;
  }
}
