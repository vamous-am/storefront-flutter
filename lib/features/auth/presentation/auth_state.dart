class AuthState {
  const AuthState({this.token, this.username});

  final String? token;
  final String? username;

  bool get isAuthenticated => token != null;

  AuthState copyWith({
    String? token,
    String? username,
  }) {
    return AuthState(
      token: token ?? this.token,
      username: username ?? this.username,
    );
  }
}
