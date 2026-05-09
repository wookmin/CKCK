import 'package:ckck_app/core/session/session_store.dart';
import 'package:ckck_app/core/network/dio_provider.dart';
import 'package:ckck_app/models/auth_state.dart';
import 'package:ckck_app/repositories/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  ref.watch(dioProvider);
  return MockAuthRepository();
  // return RemoteAuthRepository(ref.watch(dioProvider));
});

final authProvider =
    AsyncNotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

class AuthNotifier extends AsyncNotifier<AuthState> {
  @override
  Future<AuthState> build() async {
    final storage = ref.read(sessionStoreProvider);
    try {
      final token = await storage
          .read('accessToken')
          .timeout(const Duration(seconds: 1));
      final userId = await storage
          .read('userId')
          .timeout(const Duration(seconds: 1));

      if (token == null || userId == null) {
        return const AuthState.unauthenticated();
      }

      return AuthState(accessToken: token, userId: userId, isLoggedIn: true);
    } catch (_) {
      return const AuthState.unauthenticated();
    }
  }

  Future<void> login(String id, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(authRepositoryProvider);
      final storage = ref.read(sessionStoreProvider);
      final token = await repository.login(id, password);
      await storage.write('accessToken', token);
      await storage.write('userId', id);
      return AuthState(accessToken: token, userId: id, isLoggedIn: true);
    });
  }

  Future<void> logout() async {
    final storage = ref.read(sessionStoreProvider);
    await ref.read(authRepositoryProvider).logout();
    await storage.delete('accessToken');
    await storage.delete('userId');
    state = const AsyncData(AuthState.unauthenticated());
  }
}
