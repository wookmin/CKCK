class Player {
  const Player({
    required this.id,
    required this.nickname,
    required this.isReady,
    required this.role,
  });

  final String id;
  final String nickname;
  final bool isReady;
  final String role;

  Player copyWith({
    String? id,
    String? nickname,
    bool? isReady,
    String? role,
  }) {
    return Player(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      isReady: isReady ?? this.isReady,
      role: role ?? this.role,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nickname': nickname,
      'isReady': isReady,
      'role': role,
    };
  }

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'] as String,
      nickname: json['nickname'] as String,
      isReady: json['isReady'] as bool? ?? false,
      role: json['role'] as String? ?? 'thief',
    );
  }
}
