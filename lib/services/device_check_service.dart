import 'package:flutter/services.dart';

class DeviceCheckResult {
  const DeviceCheckResult({
    required this.success,
    required this.message,
  });

  final bool success;
  final String message;
}

class DeviceCheckService {
  DeviceCheckService._();

  static const MethodChannel _channel = MethodChannel(
    'ckck_app/device_checks',
  );

  static Future<DeviceCheckResult> checkEarphones() async {
    return _invoke('checkEarphones');
  }

  static Future<DeviceCheckResult> checkNfcAvailability() async {
    return _invoke('checkNfcAvailability');
  }

  static Future<DeviceCheckResult> _invoke(String method) async {
    try {
      final result = await _channel.invokeMapMethod<String, dynamic>(method);
      final success = result?['success'] == true;
      final message = (result?['message'] as String?) ?? '상태를 확인할 수 없어요.';
      return DeviceCheckResult(success: success, message: message);
    } on PlatformException catch (error) {
      return DeviceCheckResult(
        success: false,
        message: error.message ?? '기기 상태 확인 중 오류가 발생했어요.',
      );
    } catch (_) {
      return const DeviceCheckResult(
        success: false,
        message: '기기 상태 확인 중 오류가 발생했어요.',
      );
    }
  }
}
