import 'package:ckck_app/providers/auth_provider.dart';
import 'package:ckck_app/providers/pending_room_provider.dart';
import 'package:ckck_app/providers/user_provider.dart';
import 'package:ckck_app/screens/home/join_room_page.dart';
import 'package:ckck_app/screens/room/range_setting_page.dart';
import 'package:ckck_app/widgets/adaptive_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NicknamePage extends ConsumerStatefulWidget {
  const NicknamePage({
    super.key,
    required this.isHost,
  });

  final bool isHost;

  @override
  ConsumerState<NicknamePage> createState() => _NicknamePageState();
}

class _NicknamePageState extends ConsumerState<NicknamePage> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final nickname = _controller.text.trim();
    final auth = ref.read(authProvider).valueOrNull;

    if (nickname.isEmpty || auth?.userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('닉네임을 입력해 주세요.')),
      );
      return;
    }

    await ref.read(userProvider.notifier).configure(
          nickname: nickname,
          userId: auth!.userId!,
          isHost: widget.isHost,
        );
    final pendingRoomId = ref.read(pendingRoomProvider);

    if (!mounted) {
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => widget.isHost
            ? const RangeSettingPage()
            : JoinRoomPage(
                initialRoomValue: pendingRoomId,
                autoJoinOnInit: pendingRoomId != null,
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final responsive = AppResponsive.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          '닉네임 설정',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: AdaptivePage(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              color: const Color(0xFFD9D9D9),
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: TextField(
                controller: _controller,
                textAlignVertical: TextAlignVertical.center,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: '닉네임:',
                  hintStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                  ),
                ),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                ),
              ),
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
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: const RoundedRectangleBorder(),
                  ),
                  onPressed: _submit,
                  child: const Text(
                    '완료',
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
