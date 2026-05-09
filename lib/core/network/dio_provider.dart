import 'package:ckck_app/core/network/app_interceptor.dart';
import 'package:ckck_app/core/session/session_store.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dioProvider = Provider<Dio>((ref) {
  final storage = ref.watch(sessionStoreProvider);
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://example.com',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );
  dio.interceptors.add(AppInterceptor(storage));
  return dio;
});
