import 'package:dio/dio.dart';

abstract class AuthRepository {
  Future<String> login(String id, String password);
  Future<void> logout();
}

class MockAuthRepository implements AuthRepository {
  @override
  Future<String> login(String id, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    if (id.trim().isEmpty || password.trim().isEmpty) {
      throw Exception('아이디와 비밀번호를 입력해 주세요.');
    }
    if (password != '1234') {
      throw Exception('Mock 로그인 비밀번호는 1234 입니다.');
    }
    return 'mock_access_token_$id';
  }

  @override
  Future<void> logout() async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }
}

class RemoteAuthRepository implements AuthRepository {
  RemoteAuthRepository(Dio dio);

  @override
  Future<String> login(String id, String password) async {
    throw UnimplementedError(
      'RemoteAuthRepository.login will be wired when the backend API is ready.',
    );
  }

  @override
  Future<void> logout() async {
    throw UnimplementedError(
      'RemoteAuthRepository.logout will be wired when the backend API is ready.',
    );
  }
}
