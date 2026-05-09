import 'dart:math';

import 'package:ckck_app/models/room_data.dart';
import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';

abstract class RoomRepository {
  Future<String> createRoom(RoomData data);
  Future<RoomData> getRoom(String roomId);
  Future<void> joinRoom(String roomId);
  Future<void> updateRoom(String roomId, RoomData data);
}

class MockRoomRepository implements RoomRepository {
  static final Map<String, RoomData> _rooms = <String, RoomData>{};
  static final Random _random = Random();

  RoomData _prototypeRoom([String? roomId]) {
    return RoomData(
      polygon: const [
        LatLng(37.5669, 126.9768),
        LatLng(37.5669, 126.9797),
        LatLng(37.5652, 126.9797),
        LatLng(37.5652, 126.9768),
      ],
      jailLocation: const LatLng(37.5661, 126.9782),
      gameDurationSeconds: 600,
      hideTimeSeconds: 120,
      taskLevel: '중',
      policeAbility: roomId == null ? '기본 추적' : '기본 추적 / 프로토타입',
    );
  }

  @override
  Future<String> createRoom(RoomData data) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final roomId = 'ROOM-${1000 + _random.nextInt(9000)}';
    _rooms[roomId] = data;
    return roomId;
  }

  @override
  Future<RoomData> getRoom(String roomId) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return _rooms.putIfAbsent(roomId, () => _prototypeRoom(roomId));
  }

  @override
  Future<void> joinRoom(String roomId) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    _rooms.putIfAbsent(roomId, () => _prototypeRoom(roomId));
  }

  @override
  Future<void> updateRoom(String roomId, RoomData data) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    _rooms[roomId] = data;
  }
}

class RemoteRoomRepository implements RoomRepository {
  RemoteRoomRepository(Dio dio);

  @override
  Future<String> createRoom(RoomData data) async {
    throw UnimplementedError(
      'RemoteRoomRepository.createRoom will be wired when the backend API is ready.',
    );
  }

  @override
  Future<RoomData> getRoom(String roomId) async {
    throw UnimplementedError(
      'RemoteRoomRepository.getRoom will be wired when the backend API is ready.',
    );
  }

  @override
  Future<void> joinRoom(String roomId) async {
    throw UnimplementedError(
      'RemoteRoomRepository.joinRoom will be wired when the backend API is ready.',
    );
  }

  @override
  Future<void> updateRoom(String roomId, RoomData data) async {
    throw UnimplementedError(
      'RemoteRoomRepository.updateRoom will be wired when the backend API is ready.',
    );
  }
}
