import 'package:ckck_app/providers/auth_provider.dart';
import 'package:ckck_app/providers/user_provider.dart';
import 'package:ckck_app/screens/home/join_room_page.dart';
import 'package:ckck_app/screens/room/range_setting_page.dart';
import 'package:ckck_app/widgets/primary_button.dart';
import 'package:ckck_app/widgets/section_card.dart';
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

  void _submit() {
    final nickname = _controller.text.trim();
    final auth = ref.read(authProvider).valueOrNull;

    if (nickname.isEmpty || auth?.userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('닉네임을 입력해 주세요.')),
      );
      return;
    }

    ref.read(userProvider.notifier).configure(
          nickname: nickname,
          userId: auth!.userId!,
          isHost: widget.isHost,
        );

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            widget.isHost ? const RangeSettingPage() : const JoinRoomPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('닉네임 설정')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SectionCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.isHost ? '방장 닉네임' : '참가자 닉네임',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: '닉네임 입력',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                PrimaryButton(
                  label: '완료',
                  icon: Icons.check_rounded,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
