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
  RemoteAuthRepository(this._dio);

  final Dio _dio;

  @override
  Future<String> login(String id, String password) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: {'id': id, 'password': password},
    );
    return response.data?['accessToken'] as String;
  }

  @override
  Future<void> logout() async {
    await _dio.post<void>('/auth/logout');
  }
}
