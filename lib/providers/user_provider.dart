import 'package:ckck_app/models/user_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userProvider = NotifierProvider<UserNotifier, UserState>(UserNotifier.new);

class UserNotifier extends Notifier<UserState> {
  @override
  UserState build() => const UserState.initial();

  void configure({
    required String nickname,
    required String userId,
    required bool isHost,
  }) {
    state = state.copyWith(
      nickname: nickname,
      userId: userId,
      isHost: isHost,
      role: isHost ? 'thief' : state.role,
    );
  }

  void updateRole(String role) {
    state = state.copyWith(role: role);
  }
}
