import 'package:fake_store_app/core/errors/exceptions.dart';
import 'package:fake_store_app/features/auth/data/auth_local_datasource.dart';
import 'package:fake_store_app/features/auth/data/auth_remote_datasource.dart';
import 'package:fake_store_app/features/auth/data/auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

void main() {
  late MockAuthRemoteDataSource mockRemoteDataSource;
  late MockAuthLocalDataSource mockLocalDataSource;
  late AuthRepositoryImpl authRepository;

  setUp(() {
    mockRemoteDataSource = MockAuthRemoteDataSource();
    mockLocalDataSource = MockAuthLocalDataSource();
    authRepository = AuthRepositoryImpl(mockRemoteDataSource, mockLocalDataSource);
  });

  group('login', () {
    const tUsername = 'test_user';
    const tPassword = 'test_password';
    const tToken = 'jwt_token';

    test('should save token and username locally and return token when remote login is successful', () async {
      when(() => mockRemoteDataSource.login(tUsername, tPassword))
          .thenAnswer((_) async => tToken);
      when(() => mockLocalDataSource.saveToken(tToken))
          .thenAnswer((_) async {});
      when(() => mockLocalDataSource.saveUsername(tUsername))
          .thenAnswer((_) async {});

      final result = await authRepository.login(tUsername, tPassword);

      expect(result, equals(tToken));
      verify(() => mockRemoteDataSource.login(tUsername, tPassword)).called(1);
      verify(() => mockLocalDataSource.saveToken(tToken)).called(1);
      verify(() => mockLocalDataSource.saveUsername(tUsername)).called(1);
    });

    test('should throw Exception and not save locally when remote login fails', () async {
      when(() => mockRemoteDataSource.login(tUsername, tPassword))
          .thenThrow(const AuthException('Invalid username or password.'));

      expect(
        () => authRepository.login(tUsername, tPassword),
        throwsA(isA<AuthException>()),
      );
      verify(() => mockRemoteDataSource.login(tUsername, tPassword)).called(1);
      verifyNever(() => mockLocalDataSource.saveToken(any()));
      verifyNever(() => mockLocalDataSource.saveUsername(any()));
    });
  });

  group('logout', () {
    test('should clear local datasource', () async {
      when(() => mockLocalDataSource.clear()).thenAnswer((_) async {});

      await authRepository.logout();

      verify(() => mockLocalDataSource.clear()).called(1);
    });
  });

  group('getStoredToken', () {
    test('should return token from local datasource', () {
      const tToken = 'saved_token';
      when(() => mockLocalDataSource.getToken()).thenReturn(tToken);

      final result = authRepository.getStoredToken();

      expect(result, equals(tToken));
      verify(() => mockLocalDataSource.getToken()).called(1);
    });

    test('should return null when no token is saved', () {
      when(() => mockLocalDataSource.getToken()).thenReturn(null);

      final result = authRepository.getStoredToken();

      expect(result, isNull);
      verify(() => mockLocalDataSource.getToken()).called(1);
    });
  });

  group('getStoredUsername', () {
    test('should return username from local datasource', () {
      const tUsername = 'saved_username';
      when(() => mockLocalDataSource.getUsername()).thenReturn(tUsername);

      final result = authRepository.getStoredUsername();

      expect(result, equals(tUsername));
      verify(() => mockLocalDataSource.getUsername()).called(1);
    });

    test('should return null when no username is saved', () {
      when(() => mockLocalDataSource.getUsername()).thenReturn(null);

      final result = authRepository.getStoredUsername();

      expect(result, isNull);
      verify(() => mockLocalDataSource.getUsername()).called(1);
    });
  });
}
