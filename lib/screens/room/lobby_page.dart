import 'package:ckck_app/core/links/room_invite_link.dart';
import 'package:ckck_app/models/player.dart';
import 'package:ckck_app/providers/auth_provider.dart';
import 'package:ckck_app/providers/players_provider.dart';
import 'package:ckck_app/providers/room_provider.dart';
import 'package:ckck_app/providers/user_provider.dart';
import 'package:ckck_app/providers/ws_provider.dart';
import 'package:ckck_app/screens/room/range_setting_page.dart';
import 'package:ckck_app/widgets/adaptive_page.dart';
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
    final responsive = AppResponsive.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text('로비 ${widget.roomId}'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            responsive.horizontalPadding,
            8,
            responsive.horizontalPadding,
            responsive.isSmallPhone ? 14 : 18,
          ),
          child: Column(
            children: [
              _MockLobbyTabBar(controller: _tabController),
              const SizedBox(height: 18),
              Expanded(
                child: TabBarView(
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
                      roomId: widget.roomId,
                      isHost: user.isHost,
                      gameTime: room.gameTime,
                      hideTime: room.hideTime,
                      policeCount: policeCount,
                      taskLevelController: _taskLevelController,
                      policeAbilityController: _policeAbilityController,
                      players: players,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MockLobbyTabBar extends StatelessWidget {
  const _MockLobbyTabBar({required this.controller});

  final TabController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: TabBar(
        controller: controller,
        indicator: BoxDecoration(
          color: const Color(0xFFCACACA),
          border: Border.all(color: const Color(0xFFC7C7C7)),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.black,
        unselectedLabelColor: Colors.black,
        dividerColor: Colors.transparent,
        padding: EdgeInsets.zero,
        labelPadding: EdgeInsets.zero,
        splashFactory: NoSplash.splashFactory,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        tabs: const [
          Tab(text: '게임 범위'),
          Tab(text: '참여자'),
          Tab(text: '게임 규칙'),
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

  void _startGame(BuildContext context, WidgetRef ref) {
    final room = ref.read(roomProvider);
    ref.read(wsProvider.notifier).startGame({
      'roomId': roomId,
      'gameTime': room.gameTime,
      'hideTime': room.hideTime,
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('GAME_START 이벤트를 보냈습니다.')),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final room = ref.watch(roomProvider);
    final user = ref.watch(userProvider);
    final players = ref.watch(playersProvider);
    final isReady = players.any(
      (player) => player.id == user.userId && player.isReady,
    );
    final points = room.polygonPoints;
    final center = points.isNotEmpty ? points.first : const LatLng(37.5665, 126.9780);
    final responsive = AppResponsive.of(context);

    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              Positioned.fill(
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
                            color: const Color(0x40FF6B6B),
                            borderStrokeWidth: 3,
                            borderColor: const Color(0xFFFF3B30),
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
                            color: const Color(0x44FF3B30),
                            borderColor: const Color(0xFFFF3B30),
                            borderStrokeWidth: 2,
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              Positioned(
                left: 20,
                top: 22,
                child: DecoratedBox(
                  decoration: const BoxDecoration(color: Colors.white70),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        _LegendRow(
                          color: Colors.transparent,
                          borderColor: Color(0xFFFF3B30),
                          label: '전체 범위',
                        ),
                        SizedBox(height: 10),
                        _LegendRow(
                          color: Color(0xFFFF3B30),
                          borderColor: Color(0xFFFF3B30),
                          label: '감옥 위치',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        if (isHost)
          AdaptiveActionGroup(
            spacing: responsive.useStackedActions ? 12 : 18,
            children: [
              _MockRectButton(
                label: '수정하기',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const RangeSettingPage(),
                    ),
                  );
                },
              ),
              _MockRectButton(
                label: '게임 시작',
                onPressed: () => _startGame(context, ref),
              ),
            ],
          )
        else
          Center(
            child: SizedBox(
              width: 150,
              child: _ReadyButton(
                enabled: !isReady,
                onPressed: () => ref.read(wsProvider.notifier).sendReady(user.userId),
              ),
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

  Future<void> _copyInviteLink(BuildContext context) async {
    final inviteLink = buildRoomInviteLink(roomId);
    await Clipboard.setData(ClipboardData(text: inviteLink));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('방 링크를 복사했습니다.')),
      );
    }
  }

  Future<void> _showInviteDialog(BuildContext context) async {
    final inviteLink = buildRoomInviteLink(roomId);
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 18),
          child: Container(
            padding: const EdgeInsets.fromLTRB(18, 26, 18, 14),
            color: const Color(0xFFD9D9D9),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '총 인원 ${players.length.toString().padLeft(2, '0')}명 | 경찰 ${policeCount.toString().padLeft(2, '0')}명',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black54),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '참여 코드 : $roomId',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '방 링크 : $inviteLink',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 14),
                      AdaptiveActionGroup(
                        spacing: 12,
                        children: [
                          _MockRectButton(
                            label: '복사하기',
                            onPressed: () => _copyInviteLink(context),
                          ),
                          _MockRectButton(
                            label: '공유하기',
                            onPressed: () => _copyInviteLink(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Container(
                        width: 196,
                        height: 196,
                        color: Colors.white,
                        alignment: Alignment.center,
                        child: QrImageView(
                          data: inviteLink,
                          version: QrVersions.auto,
                          size: 176,
                          backgroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: 70,
                        child: _MockRectButton(
                          label: '닫기',
                          onPressed: () => Navigator.of(dialogContext).pop(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showPoliceDialog(BuildContext context, WidgetRef ref) async {
    final candidates = players.where((player) => player.role != 'police').toList();

    if (candidates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('경찰로 지정할 플레이어가 없어요.')),
      );
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '경찰 지정',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 14),
                ...candidates.map(
                  (player) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Expanded(child: Text(player.nickname)),
                        SizedBox(
                          width: 92,
                          child: _MockRectButton(
                            label: '지정',
                            onPressed: () {
                              ref.read(wsProvider.notifier).assignPolice(player.id);
                              Navigator.of(dialogContext).pop();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _playerLine(Player player) {
    final status = <String>[];
    if (player.isReady) {
      status.add('준비');
    }
    if (player.role == 'police') {
      status.add('경찰');
    }

    if (status.isEmpty) {
      return player.nickname;
    }

    if (status.length == 1 && status.first == '준비') {
      return '${player.nickname} (준비)';
    }

    if (status.length == 1 && status.first == '경찰') {
      return '${player.nickname} - 경찰';
    }

    return '${player.nickname} (준비) - 경찰';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final isReady = players.any(
      (player) => player.id == user.userId && player.isReady,
    );
    final responsive = AppResponsive.of(context);

    return Column(
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
            color: const Color(0xFFD9D9D9),
            padding: const EdgeInsets.fromLTRB(18, 26, 18, 26),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '총 인원 ${players.length.toString().padLeft(2, '0')}명 | 경찰 ${policeCount.toString().padLeft(2, '0')}명',
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 22),
                Expanded(
                  child: ListView.separated(
                    itemCount: players.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final player = players[index];
                      return Text(
                        '• ${_playerLine(player)}',
                        style: const TextStyle(fontSize: 18),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        if (isHost) ...[
          const SizedBox(height: 18),
          AdaptiveActionGroup(
            spacing: responsive.useStackedActions ? 12 : 18,
            children: [
              _MockRectButton(
                label: '초대하기',
                onPressed: () => _showInviteDialog(context),
              ),
              _MockRectButton(
                label: '경찰 지정',
                onPressed: () => _showPoliceDialog(context, ref),
              ),
            ],
          ),
        ] else ...[
          const SizedBox(height: 18),
          Center(
            child: SizedBox(
              width: 150,
              child: _ReadyButton(
                enabled: !isReady,
                onPressed: () => ref.read(wsProvider.notifier).sendReady(user.userId),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _LobbyRulesTab extends ConsumerWidget {
  const _LobbyRulesTab({
    required this.roomId,
    required this.isHost,
    required this.gameTime,
    required this.hideTime,
    required this.policeCount,
    required this.taskLevelController,
    required this.policeAbilityController,
    required this.players,
  });

  final String roomId;
  final bool isHost;
  final int gameTime;
  final int hideTime;
  final int policeCount;
  final TextEditingController taskLevelController;
  final TextEditingController policeAbilityController;
  final List<Player> players;

  String _formatLongTime(int totalSeconds) {
    final minute = totalSeconds ~/ 60;
    final hour = minute ~/ 60;
    final remainingMinute = minute % 60;
    return '${hour.toString().padLeft(2, '0')}시간 ${remainingMinute.toString().padLeft(2, '0')}분';
  }

  String _formatMinuteOnly(int totalSeconds) {
    final minute = totalSeconds ~/ 60;
    return '${minute.toString().padLeft(2, '0')}분';
  }

  void _startGame(BuildContext context, WidgetRef ref) {
    final room = ref.read(roomProvider);
    ref.read(wsProvider.notifier).startGame({
      'roomId': roomId,
      'gameTime': room.gameTime,
      'hideTime': room.hideTime,
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('GAME_START 이벤트를 보냈습니다.')),
    );
  }

  void _saveRules(BuildContext context, WidgetRef ref) {
    ref.read(roomProvider.notifier).setRules(
          taskLevel: taskLevelController.text.trim().isEmpty
              ? '중'
              : taskLevelController.text.trim(),
          policeAbility: policeAbilityController.text.trim().isEmpty
              ? '기본 추적'
              : taskLevelController.text.trim().isEmpty
                  ? '기본 추적'
                  : policeAbilityController.text.trim(),
        );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('규칙을 저장했습니다.')),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final room = ref.watch(roomProvider);
    final user = ref.watch(userProvider);
    final isReady = players.any(
      (player) => player.id == user.userId && player.isReady,
    );
    final policePlayers = players.where((player) => player.role == 'police').toList();
    final responsive = AppResponsive.of(context);

    return Column(
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
            color: const Color(0xFFD9D9D9),
            padding: const EdgeInsets.fromLTRB(18, 24, 18, 24),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '게임 제한 시간 : ${_formatLongTime(gameTime)}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '도둑이 숨을 시간 : ${_formatMinuteOnly(hideTime)}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 24),
                  if (isHost) ...[
                    const Text(
                      '도둑 테스크 레벨',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: taskLevelController,
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                  ] else
                    Text(
                      '도둑 테스크 레벨 : ${room.taskLevel}',
                      style: const TextStyle(fontSize: 18),
                    ),
                  if (!isHost) const SizedBox(height: 8),
                  if (!isHost)
                    const Text(
                      '• 00%에서 능력 해제',
                      style: TextStyle(fontSize: 18),
                    ),
                  const SizedBox(height: 26),
                  Text(
                    '경찰 인원 : ${policeCount.toString().padLeft(2, '0')}명',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  if (policePlayers.isEmpty)
                    const Text(
                      '• 아직 지정된 경찰이 없습니다',
                      style: TextStyle(fontSize: 18),
                    )
                  else
                    ...policePlayers.map(
                      (player) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          '• ${player.nickname}',
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  const SizedBox(height: 26),
                  if (isHost) ...[
                    const Text(
                      '경찰 능력',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: policeAbilityController,
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ] else ...[
                    Text(
                      '경찰 능력 : ${room.policeAbility}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• 위치 탐지',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• 소리 알림',
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        if (isHost)
          AdaptiveActionGroup(
            spacing: responsive.useStackedActions ? 12 : 18,
            children: [
              _MockRectButton(
                label: '수정하기',
                onPressed: () => _saveRules(context, ref),
              ),
              _MockRectButton(
                label: '게임 시작',
                onPressed: () => _startGame(context, ref),
              ),
            ],
          )
        else
          Center(
            child: SizedBox(
              width: 150,
              child: _ReadyButton(
                enabled: !isReady,
                onPressed: () => ref.read(wsProvider.notifier).sendReady(user.userId),
              ),
            ),
          ),
      ],
    );
  }
}

class _ReadyButton extends StatelessWidget {
  const _ReadyButton({
    required this.enabled,
    required this.onPressed,
  });

  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return _MockRectButton(
      label: '준비 완료',
      onPressed: enabled ? onPressed : null,
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.color,
    required this.borderColor,
    required this.label,
  });

  final Color color;
  final Color borderColor;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            border: Border.all(color: borderColor, width: 1.4),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _MockRectButton extends StatelessWidget {
  const _MockRectButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFFD9D9D9),
        foregroundColor: Colors.black,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 17),
        shape: const RoundedRectangleBorder(),
      ),
      onPressed: onPressed,
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
