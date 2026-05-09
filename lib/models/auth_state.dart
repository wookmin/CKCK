class AuthState {
  const AuthState({
    required this.accessToken,
    required this.userId,
    required this.isLoggedIn,
  });

  const AuthState.unauthenticated()
      : accessToken = null,
        userId = null,
        isLoggedIn = false;

  final String? accessToken;
  final String? userId;
  final bool isLoggedIn;
}
