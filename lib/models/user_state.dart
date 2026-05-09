class UserState {
  const UserState({
    required this.nickname,
    required this.userId,
    required this.isHost,
    required this.role,
  });

  const UserState.initial()
      : nickname = '',
        userId = '',
        isHost = false,
        role = 'thief';

  final String nickname;
  final String userId;
  final bool isHost;
  final String role;

  UserState copyWith({
    String? nickname,
    String? userId,
    bool? isHost,
    String? role,
  }) {
    return UserState(
      nickname: nickname ?? this.nickname,
      userId: userId ?? this.userId,
      isHost: isHost ?? this.isHost,
      role: role ?? this.role,
    );
  }
}
