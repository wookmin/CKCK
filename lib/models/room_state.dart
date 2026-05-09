import 'package:latlong2/latlong.dart';

class RoomState {
  const RoomState({
    required this.roomId,
    required this.polygonPoints,
    required this.jailLatLng,
    required this.gameTime,
    required this.hideTime,
    required this.taskLevel,
    required this.policeAbility,
  });

  const RoomState.initial()
      : roomId = null,
        polygonPoints = const [],
        jailLatLng = null,
        gameTime = 600,
        hideTime = 120,
        taskLevel = '중',
        policeAbility = '기본 추적';

  final String? roomId;
  final List<LatLng> polygonPoints;
  final LatLng? jailLatLng;
  final int gameTime;
  final int hideTime;
  final String taskLevel;
  final String policeAbility;

  RoomState copyWith({
    String? roomId,
    List<LatLng>? polygonPoints,
    LatLng? jailLatLng,
    int? gameTime,
    int? hideTime,
    String? taskLevel,
    String? policeAbility,
  }) {
    return RoomState(
      roomId: roomId ?? this.roomId,
      polygonPoints: polygonPoints ?? this.polygonPoints,
      jailLatLng: jailLatLng ?? this.jailLatLng,
      gameTime: gameTime ?? this.gameTime,
      hideTime: hideTime ?? this.hideTime,
      taskLevel: taskLevel ?? this.taskLevel,
      policeAbility: policeAbility ?? this.policeAbility,
    );
  }
}
