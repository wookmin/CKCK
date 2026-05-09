import 'package:ckck_app/core/network/dio_provider.dart';
import 'package:ckck_app/models/room_data.dart';
import 'package:ckck_app/models/room_state.dart';
import 'package:ckck_app/repositories/room_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

final roomRepositoryProvider = Provider<RoomRepository>((ref) {
  ref.watch(dioProvider);
  return MockRoomRepository();
  // return RemoteRoomRepository(ref.watch(dioProvider));
});

final roomProvider = NotifierProvider<RoomNotifier, RoomState>(RoomNotifier.new);

class RoomNotifier extends Notifier<RoomState> {
  @override
  RoomState build() => const RoomState.initial();

  void setPolygonPoints(List<LatLng> points) {
    state = state.copyWith(polygonPoints: points);
  }

  void addPolygonPoint(LatLng point) {
    state = state.copyWith(
      polygonPoints: <LatLng>[...state.polygonPoints, point],
    );
  }

  void clearPolygon() {
    state = state.copyWith(polygonPoints: const []);
  }

  void setJailLocation(LatLng point) {
    state = state.copyWith(jailLatLng: point);
  }

  void setTimes({
    required int gameTime,
    required int hideTime,
  }) {
    state = state.copyWith(gameTime: gameTime, hideTime: hideTime);
  }

  void setRules({
    required String taskLevel,
    required String policeAbility,
  }) {
    state = state.copyWith(
      taskLevel: taskLevel,
      policeAbility: policeAbility,
    );
  }

  void setRoomId(String roomId) {
    state = state.copyWith(roomId: roomId);
  }

  void hydrateFromRoomData(RoomData data, {String? roomId}) {
    state = state.copyWith(
      roomId: roomId ?? state.roomId,
      polygonPoints: data.polygon,
      jailLatLng: data.jailLocation,
      gameTime: data.gameDurationSeconds,
      hideTime: data.hideTimeSeconds,
    );
  }

  RoomData toRoomData() {
    return RoomData(
      polygon: state.polygonPoints,
      jailLocation: state.jailLatLng!,
      gameDurationSeconds: state.gameTime,
      hideTimeSeconds: state.hideTime,
    );
  }
}
