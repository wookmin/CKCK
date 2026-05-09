import 'package:ckck_app/core/session/session_store.dart';
import 'package:ckck_app/models/user_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userProvider = NotifierProvider<UserNotifier, UserState>(UserNotifier.new);

const _nicknameKey = 'nickname';
const _userIdKey = 'userId';
const _isHostKey = 'isHost';

class UserNotifier extends Notifier<UserState> {
  @override
  UserState build() => const UserState.initial();

  Future<void> configure({
    required String nickname,
    required String userId,
    required bool isHost,
  }) async {
    state = state.copyWith(
      nickname: nickname,
      userId: userId,
      isHost: isHost,
      role: isHost ? 'thief' : state.role,
    );
    final store = ref.read(sessionStoreProvider);
    await store.write(_nicknameKey, nickname);
    await store.write(_userIdKey, userId);
    await store.write(_isHostKey, isHost.toString());
  }

  void updateRole(String role) {
    state = state.copyWith(role: role);
  }

  Future<void> restore() async {
    final store = ref.read(sessionStoreProvider);
    final nickname = await store.read(_nicknameKey) ?? '';
    final userId = await store.read(_userIdKey) ?? '';
    final isHost = (await store.read(_isHostKey)) == 'true';

    if (nickname.isEmpty || userId.isEmpty) {
      state = const UserState.initial();
      return;
    }

    state = state.copyWith(
      nickname: nickname,
      userId: userId,
      isHost: isHost,
      role: isHost ? 'thief' : state.role,
    );
  }

  Future<void> clear() async {
    state = const UserState.initial();
    final store = ref.read(sessionStoreProvider);
    await store.delete(_nicknameKey);
    await store.delete(_userIdKey);
    await store.delete(_isHostKey);
  }
}
