import 'package:shared_preferences/shared_preferences.dart';

class AuthLocalDataSource {
  AuthLocalDataSource(this._sharedPreferences);

  final SharedPreferences _sharedPreferences;

  static const _tokenKey = 'auth_token';
  static const _usernameKey = 'auth_username';

  Future<void> saveToken(String token) async {
    await _sharedPreferences.setString(_tokenKey, token);
  }

  String? getToken() {
    return _sharedPreferences.getString(_tokenKey);
  }

  Future<void> saveUsername(String username) async {
    await _sharedPreferences.setString(_usernameKey, username);
  }

  String? getUsername() {
    return _sharedPreferences.getString(_usernameKey);
  }

  Future<void> clear() async {
    await _sharedPreferences.remove(_tokenKey);
    await _sharedPreferences.remove(_usernameKey);
  }
}
