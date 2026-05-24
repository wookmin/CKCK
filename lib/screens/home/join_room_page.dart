import 'package:ckck_app/providers/room_provider.dart';
import 'package:ckck_app/screens/home/nickname_page.dart';
import 'package:ckck_app/widgets/mockup_background_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class JoinRoomPage extends ConsumerStatefulWidget {
  const JoinRoomPage({super.key});

  @override
  ConsumerState<JoinRoomPage> createState() => _JoinRoomPageState();
}

class _JoinRoomPageState extends ConsumerState<JoinRoomPage> {
  final _roomController = TextEditingController();
  bool _joining = false;
  bool _showQrScanner = false;

  @override
  void dispose() {
    _roomController.dispose();
    super.dispose();
  }

  Future<void> _joinRoom(String rawRoomId) async {
    if (_joining) {
      return;
    }
    final roomId = rawRoomId.trim().split('/').last;
    if (roomId.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('방 코드 또는 링크를 입력해 주세요.')));
      return;
    }

    setState(() => _joining = true);

    try {
      final repository = ref.read(roomRepositoryProvider);
      await repository.joinRoom(roomId);
      final room = await repository.getRoom(roomId);
      ref.read(roomProvider.notifier).hydrateFromRoomData(room, roomId: roomId);

      if (!mounted) {
        return;
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => NicknamePage(isHost: false, roomId: roomId),
        ),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString().replaceFirst('Exception: ', '')),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _joining = false);
      }
    }
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
                    SizedBox(height: constraints.maxHeight * 0.18),
                    Image.asset(
                      'assets/enterRoomBubble.png',
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
                              controller: _roomController,
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
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: _showQrScanner
                          ? 28
                          : constraints.maxHeight * 0.12,
                    ),
                    GestureDetector(
                      onTap: _joining
                          ? null
                          : () => _joinRoom(_roomController.text),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Opacity(
                            opacity: _joining ? 0.7 : 1,
                            child: Image.asset(
                              'assets/succeedBtn.png',
                              width: 100,
                              fit: BoxFit.contain,
                            ),
                          ),
                          if (_joining)
                            const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.black,
                              ),
                            ),
                        ],
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
