import 'dart:math';

import 'package:ckck_app/models/room_data.dart';
import 'package:dio/dio.dart';

abstract class RoomRepository {
  Future<String> createRoom(RoomData data);
  Future<RoomData> getRoom(String roomId);
  Future<void> joinRoom(String roomId);
  Future<void> updateRoom(String roomId, RoomData data);
}

class MockRoomRepository implements RoomRepository {
  static final Map<String, RoomData> _rooms = <String, RoomData>{};
  static final Random _random = Random();

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
    final room = _rooms[roomId];
    if (room == null) {
      throw Exception('존재하지 않는 방입니다.');
    }
    return room;
  }

  @override
  Future<void> joinRoom(String roomId) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (!_rooms.containsKey(roomId)) {
      throw Exception('방 참여에 실패했습니다.');
    }
  }

  @override
  Future<void> updateRoom(String roomId, RoomData data) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    _rooms[roomId] = data;
  }
}

class RemoteRoomRepository implements RoomRepository {
  RemoteRoomRepository(this._dio);

  final Dio _dio;

  @override
  Future<String> createRoom(RoomData data) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/rooms',
      data: data.toJson(),
    );
    return response.data?['roomId'] as String;
  }

  @override
  Future<RoomData> getRoom(String roomId) async {
    final response = await _dio.get<Map<String, dynamic>>('/rooms/$roomId');
    return RoomData.fromJson(response.data ?? <String, dynamic>{});
  }

  @override
  Future<void> joinRoom(String roomId) async {
    await _dio.post<void>('/rooms/$roomId/join');
  }

  @override
  Future<void> updateRoom(String roomId, RoomData data) async {
    await _dio.patch<void>('/rooms/$roomId', data: data.toJson());
  }
}
