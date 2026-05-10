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
    final storage = ref.read(secureStorageProvider);
    try {
      final token = await storage
          .read(key: 'accessToken')
          .timeout(const Duration(seconds: 1));
      final userId = await storage
          .read(key: 'userId')
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
      final storage = ref.read(secureStorageProvider);
      final token = await repository.login(id, password);
      await storage.write(key: 'accessToken', value: token);
      await storage.write(key: 'userId', value: id);
      return AuthState(accessToken: token, userId: id, isLoggedIn: true);
    });
  }

  Future<void> logout() async {
    final storage = ref.read(secureStorageProvider);
    await ref.read(authRepositoryProvider).logout();
    await storage.delete(key: 'accessToken');
    await storage.delete(key: 'userId');
    state = const AsyncData(AuthState.unauthenticated());
  }
}
