import 'dart:async';

import 'package:ckck_app/models/player.dart';
import 'package:ckck_app/models/user_state.dart';
import 'package:ckck_app/providers/players_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

final wsProvider =
    NotifierProvider<WsNotifier, RoomSocketState>(WsNotifier.new);

class RoomSocketState {
  const RoomSocketState({
    required this.isConnected,
    required this.roomId,
    required this.lastEventType,
  });

  const RoomSocketState.initial()
      : isConnected = false,
        roomId = null,
        lastEventType = null;

  final bool isConnected;
  final String? roomId;
  final String? lastEventType;

  RoomSocketState copyWith({
    bool? isConnected,
    String? roomId,
    String? lastEventType,
  }) {
    return RoomSocketState(
      isConnected: isConnected ?? this.isConnected,
      roomId: roomId ?? this.roomId,
      lastEventType: lastEventType ?? this.lastEventType,
    );
  }
}

abstract class RoomSocketService {
  Stream<Map<String, dynamic>> get stream;

  Future<void> connect({
    required String roomId,
    required String token,
    required UserState user,
  });

  void send(Map<String, dynamic> message);

  Future<void> disconnect();
}

class MockRoomSocketService implements RoomSocketService {
  final StreamController<Map<String, dynamic>> _controller =
      StreamController<Map<String, dynamic>>.broadcast();
  final List<Player> _players = <Player>[];

  @override
  Stream<Map<String, dynamic>> get stream => _controller.stream;

  @override
  Future<void> connect({
    required String roomId,
    required String token,
    required UserState user,
  }) async {
    final me = Player(
      id: user.userId,
      nickname: user.nickname,
      isReady: user.isHost,
      role: user.role,
    );

    final index = _players.indexWhere((player) => player.id == me.id);
    if (index == -1) {
      _players.add(me);
    } else {
      _players[index] = me;
    }

    _controller.add({
      'type': 'PLAYER_JOINED',
      'players': _players.map((player) => player.toJson()).toList(),
    });
  }

  @override
  void send(Map<String, dynamic> message) {
    switch (message['type']) {
      case 'READY':
        final userId = message['userId'] as String;
        final index = _players.indexWhere((player) => player.id == userId);
        if (index != -1) {
          _players[index] = _players[index].copyWith(isReady: true);
        }
        _controller.add({'type': 'PLAYER_READY', 'userId': userId});
      case 'ASSIGN_POLICE':
        final targetId = message['targetId'] as String;
        final index = _players.indexWhere((player) => player.id == targetId);
        if (index != -1) {
          _players[index] = _players[index].copyWith(role: 'police');
        }
        _controller.add({
          'type': 'PLAYER_JOINED',
          'players': _players.map((player) => player.toJson()).toList(),
        });
      case 'GAME_START':
        _controller.add({'type': 'GAME_START', 'gameData': message['gameData']});
    }
  }

  @override
  Future<void> disconnect() async {
    await _controller.close();
  }
}

class RemoteRoomSocketService implements RoomSocketService {
  RemoteRoomSocketService(this._channel);

  final WebSocketChannel _channel;

  @override
  Stream<Map<String, dynamic>> get stream => _channel.stream.map(
        (event) => event as Map<String, dynamic>,
      );

  @override
  Future<void> connect({
    required String roomId,
    required String token,
    required UserState user,
  }) async {
    throw UnimplementedError(
      'RemoteRoomSocketService.connect will be wired when the backend socket is ready.',
    );
  }

  @override
  void send(Map<String, dynamic> message) {
    _channel.sink.add(message);
  }

  @override
  Future<void> disconnect() async {
    await _channel.sink.close();
  }
}

class WsNotifier extends Notifier<RoomSocketState> {
  StreamSubscription<Map<String, dynamic>>? _subscription;
  late final RoomSocketService _service;

  @override
  RoomSocketState build() {
    _service = MockRoomSocketService();
    ref.onDispose(() async {
      await _subscription?.cancel();
      await _service.disconnect();
    });
    return const RoomSocketState.initial();
  }

  Future<void> connect({
    required String roomId,
    required String token,
    required UserState user,
  }) async {
    await _subscription?.cancel();
    _subscription = _service.stream.listen(_handleEvent);
    await _service.connect(roomId: roomId, token: token, user: user);
    state = state.copyWith(isConnected: true, roomId: roomId);
  }

  void sendReady(String userId) {
    _service.send({'type': 'READY', 'userId': userId});
  }

  void assignPolice(String targetId) {
    _service.send({'type': 'ASSIGN_POLICE', 'targetId': targetId});
  }

  void startGame(Map<String, dynamic> gameData) {
    _service.send({'type': 'GAME_START', 'gameData': gameData});
  }

  void _handleEvent(Map<String, dynamic> event) {
    state = state.copyWith(lastEventType: event['type'] as String?);

    if (event['type'] == 'PLAYER_JOINED') {
      final players = (event['players'] as List<dynamic>)
          .map((item) => Player.fromJson(item as Map<String, dynamic>))
          .toList();
      ref.read(playersProvider.notifier).setPlayers(players);
      return;
    }

    if (event['type'] == 'PLAYER_READY') {
      ref.read(playersProvider.notifier).markReady(event['userId'] as String);
    }
  }
}
