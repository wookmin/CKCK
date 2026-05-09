import 'package:ckck_app/models/player.dart';
import 'package:ckck_app/providers/auth_provider.dart';
import 'package:ckck_app/providers/players_provider.dart';
import 'package:ckck_app/providers/room_provider.dart';
import 'package:ckck_app/providers/user_provider.dart';
import 'package:ckck_app/providers/ws_provider.dart';
import 'package:ckck_app/screens/room/range_setting_page.dart';
import 'package:ckck_app/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:qr_flutter/qr_flutter.dart';

class LobbyPage extends ConsumerStatefulWidget {
  const LobbyPage({
    super.key,
    required this.roomId,
  });

  final String roomId;

  @override
  ConsumerState<LobbyPage> createState() => _LobbyPageState();
}

class _LobbyPageState extends ConsumerState<LobbyPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final TextEditingController _taskLevelController;
  late final TextEditingController _policeAbilityController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    final room = ref.read(roomProvider);
    _taskLevelController = TextEditingController(text: room.taskLevel);
    _policeAbilityController = TextEditingController(text: room.policeAbility);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final auth = ref.read(authProvider).valueOrNull;
      final user = ref.read(userProvider);
      if (auth?.accessToken == null) {
        return;
      }
      await ref.read(wsProvider.notifier).connect(
            roomId: widget.roomId,
            token: auth!.accessToken!,
            user: user,
          );
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _taskLevelController.dispose();
    _policeAbilityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final room = ref.watch(roomProvider);
    final user = ref.watch(userProvider);
    final players = ref.watch(playersProvider);
    final policeCount = players.where((player) => player.role == 'police').length;

    return Scaffold(
      appBar: AppBar(
        title: Text('로비 ${widget.roomId}'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '게임 범위'),
            Tab(text: '참여자'),
            Tab(text: '게임 규칙'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _LobbyRangeTab(roomId: widget.roomId, isHost: user.isHost),
          _LobbyPlayersTab(
            roomId: widget.roomId,
            isHost: user.isHost,
            players: players,
            policeCount: policeCount,
          ),
          _LobbyRulesTab(
            isHost: user.isHost,
            gameTime: room.gameTime,
            hideTime: room.hideTime,
            taskLevelController: _taskLevelController,
            policeAbilityController: _policeAbilityController,
          ),
        ],
      ),
    );
  }
}

class _LobbyRangeTab extends ConsumerWidget {
  const _LobbyRangeTab({
    required this.roomId,
    required this.isHost,
  });

  final String roomId;
  final bool isHost;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final room = ref.watch(roomProvider);
    final points = room.polygonPoints;
    final center = points.isNotEmpty ? points.first : const LatLng(37.5665, 126.9780);

    return Column(
      children: [
        Expanded(
          child: FlutterMap(
            options: MapOptions(
              initialCenter: center,
              initialZoom: 16,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.ckck',
              ),
              if (points.isNotEmpty)
                PolygonLayer(
                  polygons: [
                    Polygon(
                      points: points,
                      color: const Color(0x3314B8A6),
                      borderStrokeWidth: 3,
                      borderColor: const Color(0xFF0F766E),
                    ),
                  ],
                ),
              if (room.jailLatLng != null)
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: room.jailLatLng!,
                      radius: 5,
                      useRadiusInMeter: true,
                      color: const Color(0x44F97316),
                      borderColor: const Color(0xFFF97316),
                      borderStrokeWidth: 2,
                    ),
                  ],
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: isHost
              ? Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const RangeSettingPage(),
                            ),
                          );
                        },
                        child: const Text('수정하기'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: PrimaryButton(
                        label: '게임 시작',
                        icon: Icons.play_circle_fill_rounded,
                        onPressed: () {
                          ref.read(wsProvider.notifier).startGame({
                            'roomId': roomId,
                            'gameTime': room.gameTime,
                            'hideTime': room.hideTime,
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('GAME_START 이벤트를 보냈습니다.')),
                          );
                        },
                      ),
                    ),
                  ],
                )
              : PrimaryButton(
                  label: '준비 완료',
                  icon: Icons.check_circle_rounded,
                  onPressed: () {
                    final user = ref.read(userProvider);
                    ref.read(wsProvider.notifier).sendReady(user.userId);
                  },
                ),
        ),
      ],
    );
  }
}

class _LobbyPlayersTab extends ConsumerWidget {
  const _LobbyPlayersTab({
    required this.roomId,
    required this.isHost,
    required this.players,
    required this.policeCount,
  });

  final String roomId;
  final bool isHost;
  final List<Player> players;
  final int policeCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '총 인원 ${players.length}명 | 경찰 $policeCount명',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: players.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final player = players[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              player.nickname,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 8,
                              children: [
                                if (player.isReady)
                                  const Chip(label: Text('준비 완료')),
                                if (player.role == 'police')
                                  const Chip(label: Text('경찰')),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (isHost)
                        TextButton(
                          onPressed: player.role == 'police'
                              ? null
                              : () {
                                  ref
                                      .read(wsProvider.notifier)
                                      .assignPolice(player.id);
                                },
                          child: const Text('경찰 지정'),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          if (isHost) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final inviteLink = 'https://ckck.app/rooms/$roomId';
                      await Clipboard.setData(ClipboardData(text: inviteLink));
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('방 링크를 복사했습니다.')),
                        );
                      }
                    },
                    icon: const Icon(Icons.link_rounded),
                    label: const Text('초대하기'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      showDialog<void>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('방 QR'),
                          content: SizedBox(
                            width: 220,
                            height: 220,
                            child: QrImageView(
                              data: 'https://ckck.app/rooms/$roomId',
                              version: QrVersions.auto,
                            ),
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.qr_code_2_rounded),
                    label: const Text('QR'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _LobbyRulesTab extends ConsumerWidget {
  const _LobbyRulesTab({
    required this.isHost,
    required this.gameTime,
    required this.hideTime,
    required this.taskLevelController,
    required this.policeAbilityController,
  });

  final bool isHost;
  final int gameTime;
  final int hideTime;
  final TextEditingController taskLevelController;
  final TextEditingController policeAbilityController;

  String _formatTime(int totalSeconds) {
    final minute = totalSeconds ~/ 60;
    final second = totalSeconds % 60;
    return '${minute.toString().padLeft(2, '0')}:${second.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final room = ref.watch(roomProvider);

    if (!isHost) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('게임 시간: ${_formatTime(gameTime)}'),
              const SizedBox(height: 12),
              Text('숨을 시간: ${_formatTime(hideTime)}'),
              const SizedBox(height: 12),
              Text('테스크 레벨: ${room.taskLevel}'),
              const SizedBox(height: 12),
              Text('경찰 능력: ${room.policeAbility}'),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: taskLevelController,
            decoration: const InputDecoration(
              labelText: '테스크 레벨',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: policeAbilityController,
            decoration: const InputDecoration(
              labelText: '경찰 능력',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '게임 시간 ${_formatTime(gameTime)} | 숨을 시간 ${_formatTime(hideTime)}',
            ),
          ),
          const SizedBox(height: 20),
          PrimaryButton(
            label: '규칙 저장',
            icon: Icons.save_rounded,
            onPressed: () {
              ref.read(roomProvider.notifier).setRules(
                    taskLevel: taskLevelController.text.trim().isEmpty
                        ? '중'
                        : taskLevelController.text.trim(),
                    policeAbility: policeAbilityController.text.trim().isEmpty
                        ? '기본 추적'
                        : policeAbilityController.text.trim(),
                  );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('규칙을 저장했습니다.')),
              );
            },
          ),
        ],
      ),
    );
  }
}
