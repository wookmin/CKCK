import 'package:ckck_app/models/player.dart';
import 'package:ckck_app/providers/players_provider.dart';
import 'package:ckck_app/providers/room_provider.dart';
import 'package:ckck_app/providers/user_provider.dart';
import 'package:ckck_app/screens/room/lobby_page.dart';
import 'package:ckck_app/widgets/room_setting_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TimeSettingPage extends ConsumerStatefulWidget {
  const TimeSettingPage({super.key});

  @override
  ConsumerState<TimeSettingPage> createState() => _TimeSettingPageState();
}

class _TimeSettingPageState extends ConsumerState<TimeSettingPage> {
  int _gameMinute = 10;
  int _gameSecond = 0;
  int _hideMinute = 2;
  int _hideSecond = 0;
  bool _creating = false;

  String _formatTime(int minute, int second) {
    return '${minute.toString().padLeft(2, '0')}:${second.toString().padLeft(2, '0')}';
  }

  Future<void> _showTimePicker({
    required String title,
    required int initialMinute,
    required int initialSecond,
    required ValueChanged<({int minute, int second})> onChanged,
  }) async {
    int selectedMinute = initialMinute;
    int selectedSecond = initialSecond;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 180,
                      child: Row(
                        children: [
                          Expanded(
                            child: _TimeWheel(
                              value: selectedMinute,
                              label: '분',
                              onChanged: (value) {
                                setModalState(() => selectedMinute = value);
                              },
                            ),
                          ),
                          Expanded(
                            child: _TimeWheel(
                              value: selectedSecond,
                              label: '초',
                              onChanged: (value) {
                                setModalState(() => selectedSecond = value);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFD9D9D9),
                          foregroundColor: Colors.black,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0),
                          ),
                        ),
                        onPressed: () {
                          onChanged((
                            minute: selectedMinute,
                            second: selectedSecond,
                          ));
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          '적용',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<bool> _confirmCreateRoom() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) {
            return Dialog(
              backgroundColor: const Color(0xFFD9D9D9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0),
              ),
              child: SizedBox(
                width: 340,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(28, 34, 28, 26),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '방을 생성하시겠습니까?',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 42),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _DialogActionButton(
                            label: '아니요',
                            onPressed: () => Navigator.of(context).pop(false),
                          ),
                          const SizedBox(width: 56),
                          _DialogActionButton(
                            label: '예',
                            onPressed: () => Navigator.of(context).pop(true),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ) ??
        false;
  }

  Future<void> _createRoom() async {
    final confirmed = await _confirmCreateRoom();
    if (!confirmed) {
      return;
    }

    setState(() => _creating = true);
    try {
      final roomNotifier = ref.read(roomProvider.notifier);
      roomNotifier.setTimes(
        gameTime: _gameMinute * 60 + _gameSecond,
        hideTime: _hideMinute * 60 + _hideSecond,
      );
      final roomId =
          await ref.read(roomRepositoryProvider).createRoom(roomNotifier.toRoomData());
      roomNotifier.setRoomId(roomId);

      final user = ref.read(userProvider);
      ref.read(playersProvider.notifier).setPlayers([
        Player(
          id: user.userId,
          nickname: user.nickname,
          isReady: true,
          role: user.role,
        ),
      ]);

      if (!mounted) {
        return;
      }

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => LobbyPage(roomId: roomId)),
        (route) => route.isFirst,
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _creating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildRoomSettingAppBar(
        context: context,
        title: '게임 시간 설정',
      ),
      body: RoomSettingBackground(
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 340),
                child: Column(
                  children: [
                    const RoomSettingInfoCard(
                      text: '시간을 눌러 게임 제한 시간과\n도둑이 숨을 시간을 설정해 주세요.',
                    ),
                    const Spacer(),
                    _TimeDisplayBlock(
                      label: '게임 제한 시간',
                      value: _formatTime(_gameMinute, _gameSecond),
                      onTap: _creating
                          ? null
                          : () => _showTimePicker(
                                title: '게임 제한 시간',
                                initialMinute: _gameMinute,
                                initialSecond: _gameSecond,
                                onChanged: (value) {
                                  setState(() {
                                    _gameMinute = value.minute;
                                    _gameSecond = value.second;
                                  });
                                },
                              ),
                    ),
                    const SizedBox(height: 36),
                    _TimeDisplayBlock(
                      label: '도둑이 숨을 시간',
                      value: _formatTime(_hideMinute, _hideSecond),
                      onTap: _creating
                          ? null
                          : () => _showTimePicker(
                                title: '도둑이 숨을 시간',
                                initialMinute: _hideMinute,
                                initialSecond: _hideSecond,
                                onChanged: (value) {
                                  setState(() {
                                    _hideMinute = value.minute;
                                    _hideSecond = value.second;
                                  });
                                },
                              ),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: 120,
                      child: RoomSettingActionButton(
                        label: '완료',
                        onPressed: _createRoom,
                        isBusy: _creating,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TimeDisplayBlock extends StatelessWidget {
  const _TimeDisplayBlock({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 14),
        Center(
          child: GestureDetector(
            onTap: onTap,
            child: SizedBox(
              width: 220,
              child: RoomSettingValueCard(
                child: Text(
                  value,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 46,
                    height: 1,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DialogActionButton extends StatelessWidget {
  const _DialogActionButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 82,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFFBEBEBE),
          foregroundColor: Colors.black,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _TimeWheel extends StatelessWidget {
  const _TimeWheel({
    required this.value,
    required this.label,
    required this.onChanged,
  });

  final int value;
  final String label;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: CupertinoPicker(
            scrollController: FixedExtentScrollController(initialItem: value),
            itemExtent: 36,
            onSelectedItemChanged: onChanged,
            children: List<Widget>.generate(
              60,
              (index) => Center(
                child: Text(index.toString().padLeft(2, '0')),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
