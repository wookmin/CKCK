import 'package:ckck_app/providers/pending_room_provider.dart';
import 'package:ckck_app/providers/user_provider.dart';
import 'package:ckck_app/screens/home/home_page.dart';
import 'package:ckck_app/screens/home/join_room_page.dart';
import 'package:ckck_app/screens/home/nickname_page.dart';
import 'package:ckck_app/widgets/adaptive_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PostLoginCheckPage extends ConsumerStatefulWidget {
  const PostLoginCheckPage({super.key});

  @override
  ConsumerState<PostLoginCheckPage> createState() => _PostLoginCheckPageState();
}

class _PostLoginCheckPageState extends ConsumerState<PostLoginCheckPage> {
  bool _earphonesChecked = false;
  bool _nfcChecked = false;

  Future<void> _continue() async {
    await ref.read(userProvider.notifier).restore();
    await ref.read(pendingRoomProvider.notifier).restore();
    final pendingRoomId = ref.read(pendingRoomProvider);
    final user = ref.read(userProvider);

    if (!mounted) {
      return;
    }

    if (pendingRoomId != null) {
      final target = user.nickname.isEmpty
          ? const NicknamePage(isHost: false)
          : JoinRoomPage(
              initialRoomValue: pendingRoomId,
              autoJoinOnInit: true,
            );
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => target),
        (route) => false,
      );
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => const HomePage(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final responsive = AppResponsive.of(context);
    return Scaffold(
      body: AdaptivePage(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '프로토타입 사전 점검',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: responsive.verticalGap),
            Text(
              '웹에서는 실제 하드웨어 검사가 아니라 테스트 흐름 확인 단계입니다.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF475569),
                  ),
            ),
            SizedBox(height: responsive.heroGap),
            _CheckActionButton(
              label: '이어폰 연결 확인',
              checked: _earphonesChecked,
              onPressed: () {
                setState(() => _earphonesChecked = !_earphonesChecked);
              },
            ),
            const SizedBox(height: 20),
            _CheckActionButton(
              label: 'NFC 작동 확인',
              checked: _nfcChecked,
              onPressed: () {
                setState(() => _nfcChecked = !_nfcChecked);
              },
            ),
            SizedBox(height: responsive.heroGap),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: responsive.primaryButtonMaxWidth),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFD9D9D9),
                    foregroundColor: Colors.black,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0),
                    ),
                  ),
                  onPressed: _continue,
                  child: const Text(
                    '시작하기',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckActionButton extends StatelessWidget {
  const _CheckActionButton({
    required this.label,
    required this.checked,
    required this.onPressed,
  });

  final String label;
  final bool checked;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: checked ? const Color(0xFFBFC7CF) : const Color(0xFFD9D9D9),
          foregroundColor: Colors.black,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          checked ? '$label 완료' : label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
