import 'package:ckck_app/providers/auth_provider.dart';
import 'package:ckck_app/providers/user_provider.dart';
import 'package:ckck_app/screens/room/lobby_page.dart';
import 'package:ckck_app/screens/room/range_setting_page.dart';
import 'package:ckck_app/widgets/mockup_background_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NicknamePage extends ConsumerStatefulWidget {
  const NicknamePage({super.key, required this.isHost, this.roomId});

  final bool isHost;
  final String? roomId;

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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('닉네임을 입력해 주세요.')));
      return;
    }

    ref
        .read(userProvider.notifier)
        .configure(
          nickname: nickname,
          userId: auth!.userId!,
          isHost: widget.isHost,
        );

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => widget.isHost
            ? const RangeSettingPage()
            : LobbyPage(roomId: widget.roomId!),
      ),
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
                      child: Image.asset('assets/logoutBtn.png', width: 56),
                    ),
                    SizedBox(height: constraints.maxHeight * 0.2),
                    Image.asset(
                      'assets/enterNickname.png',
                      width: constraints.maxWidth * 0.72,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: constraints.maxWidth * 0.84,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.asset(
                            'assets/codeBlank.png',
                            fit: BoxFit.fitWidth,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 22),
                            child: TextField(
                              controller: _controller,
                              textAlignVertical: TextAlignVertical.center,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintStyle: TextStyle(
                                  color: Color(0x66000000),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: constraints.maxHeight * 0.12),
                    GestureDetector(
                      onTap: _submit,
                      child: Image.asset(
                        'assets/succeedBtn.png',
                        width: 100,
                        fit: BoxFit.contain,
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
