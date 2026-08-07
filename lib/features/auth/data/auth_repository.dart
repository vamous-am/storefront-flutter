import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/network/api_client.dart';
import 'auth_local_datasource.dart';
import 'auth_remote_datasource.dart';

abstract class AuthRepository {
  Future<String> login(String username, String password);
  Future<void> logout();
  String? getStoredToken();
  String? getStoredUsername();
}

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remoteDataSource, this._localDataSource);

  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  @override
  Future<String> login(String username, String password) async {
    final token = await _remoteDataSource.login(username, password);
    await _localDataSource.saveToken(token);
    await _localDataSource.saveUsername(username);
    return token;
  }

  @override
  Future<void> logout() async {
    await _localDataSource.clear();
  }

  @override
  String? getStoredToken() {
    return _localDataSource.getToken();
  }

  @override
  String? getStoredUsername() {
    return _localDataSource.getUsername();
  }
}

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden in ProviderScope');
});

final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  return AuthLocalDataSource(ref.watch(sharedPreferencesProvider));
});

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(ref.watch(apiClientProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.watch(authRemoteDataSourceProvider),
    ref.watch(authLocalDataSourceProvider),
  );
});
