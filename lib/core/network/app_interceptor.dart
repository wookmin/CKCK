import 'package:dio/dio.dart';
import 'package:ckck_app/core/session/session_store.dart';

class AppInterceptor extends Interceptor {
  AppInterceptor(this._storage);

  final SessionStore _storage;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.read('accessToken');
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // 실제 API 연결 시 토큰 재발급 또는 로그인 화면 이동 처리.
    }
    super.onError(err, handler);
  }
}
