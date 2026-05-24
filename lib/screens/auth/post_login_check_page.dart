import 'package:ckck_app/providers/auth_provider.dart';
import 'package:ckck_app/screens/auth/login_page.dart';
import 'package:ckck_app/screens/home/home_page.dart';
import 'package:ckck_app/services/device_check_service.dart';
import 'package:ckck_app/widgets/mockup_background_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PostLoginCheckPage extends ConsumerStatefulWidget {
  const PostLoginCheckPage({super.key});

  @override
  ConsumerState<PostLoginCheckPage> createState() =>
      _PostLoginCheckPageState();
}

class _PostLoginCheckPageState extends ConsumerState<PostLoginCheckPage> {
  _DeviceCheckStatus _earphonesStatus = _DeviceCheckStatus.idle;
  _DeviceCheckStatus _nfcStatus = _DeviceCheckStatus.idle;
  bool _loggingOut = false;

  bool get _canStart =>
      _earphonesStatus == _DeviceCheckStatus.success &&
      _nfcStatus == _DeviceCheckStatus.success;

  Future<void> _runEarphonesCheck() async {
    if (_earphonesStatus == _DeviceCheckStatus.checking) {
      return;
    }

    setState(() => _earphonesStatus = _DeviceCheckStatus.checking);
    final result = await DeviceCheckService.checkEarphones();

    if (!mounted) {
      return;
    }

    setState(() {
      _earphonesStatus = result.success
          ? _DeviceCheckStatus.success
          : _DeviceCheckStatus.failure;
    });
    _showStatusMessage(result.message);
  }

  Future<void> _runNfcCheck() async {
    if (_nfcStatus == _DeviceCheckStatus.checking) {
      return;
    }

    setState(() => _nfcStatus = _DeviceCheckStatus.checking);
    final result = await DeviceCheckService.checkNfcAvailability();

    if (!mounted) {
      return;
    }

    setState(() {
      _nfcStatus = result.success
          ? _DeviceCheckStatus.success
          : _DeviceCheckStatus.failure;
    });
    _showStatusMessage(result.message);
  }

  void _showStatusMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _logout() async {
    if (_loggingOut) {
      return;
    }

    setState(() => _loggingOut = true);
    await ref.read(authProvider.notifier).logout();

    if (!mounted) {
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MockupBackgroundScaffold(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: GestureDetector(
                        onTap: _logout,
                        child: Opacity(
                          opacity: _loggingOut ? 0.7 : 1,
                          child: Image.asset('assets/logoutBtn.png', width: 56),
                        ),
                      ),
                    ),
                    SizedBox(height: constraints.maxHeight * 0.01),
                    Image.asset(
                      'assets/prepareBubble.png',
                      width: constraints.maxWidth * 0.7,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: constraints.maxHeight * 0.005),
                    _CheckAssetButton(
                      assetPath: 'assets/airpodcheck.png',
                      width: constraints.maxWidth * 0.84,
                      status: _earphonesStatus,
                      onTap: _runEarphonesCheck,
                    ),
                    const SizedBox(height: 18),
                    _CheckAssetButton(
                      assetPath: 'assets/nfcCheck.png',
                      width: constraints.maxWidth * 0.84,
                      status: _nfcStatus,
                      onTap: _runNfcCheck,
                    ),
                    SizedBox(height: constraints.maxHeight * 0.1),
                    GestureDetector(
                      onTap: _canStart
                          ? () {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute<void>(
                            builder: (_) => const HomePage(),
                          ),
                          (route) => false,
                        );
                      }
                          : () {
                              _showStatusMessage(
                                '이어폰 연결과 NFC 확인을 모두 완료해 주세요.',
                              );
                            },
                      child: Opacity(
                        opacity: _canStart ? 1 : 0.55,
                        child: Image.asset(
                          'assets/succeedBtn.png',
                          width: 100,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CheckAssetButton extends StatelessWidget {
  const _CheckAssetButton({
    required this.assetPath,
    required this.width,
    required this.status,
    required this.onTap,
  });

  final String assetPath;
  final double width;
  final _DeviceCheckStatus status;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Opacity(
            opacity: status == _DeviceCheckStatus.checking ? 0.75 : 1,
            child: Image.asset(assetPath, width: width, fit: BoxFit.fitWidth),
          ),
          if (status == _DeviceCheckStatus.success)
            Positioned(
              top: 8,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFC400),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.black, width: 2),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check, size: 14, color: Colors.black),
                    SizedBox(width: 4),
                    Text(
                      '완료',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (status == _DeviceCheckStatus.failure)
            Positioned(
              top: 8,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE0E0),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.black, width: 2),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.close, size: 14, color: Colors.black),
                    SizedBox(width: 4),
                    Text(
                      '실패',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (status == _DeviceCheckStatus.checking)
            const Positioned(
              right: 18,
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.black,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

enum _DeviceCheckStatus {
  idle,
  checking,
  success,
  failure,
}
