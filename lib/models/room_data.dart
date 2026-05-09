import 'package:latlong2/latlong.dart';

class RoomData {
  const RoomData({
    required this.polygon,
    required this.jailLocation,
    required this.gameDurationSeconds,
    required this.hideTimeSeconds,
    required this.taskLevel,
    required this.policeAbility,
  });

  final List<LatLng> polygon;
  final LatLng jailLocation;
  final int gameDurationSeconds;
  final int hideTimeSeconds;
  final String taskLevel;
  final String policeAbility;

  Map<String, dynamic> toJson() {
    return {
      'polygon': polygon
          .map((point) => {'lat': point.latitude, 'lng': point.longitude})
          .toList(),
      'jailLocation': {
        'lat': jailLocation.latitude,
        'lng': jailLocation.longitude,
      },
      'gameDurationSeconds': gameDurationSeconds,
      'hideTimeSeconds': hideTimeSeconds,
      'taskLevel': taskLevel,
      'policeAbility': policeAbility,
    };
  }

  factory RoomData.fromJson(Map<String, dynamic> json) {
    return RoomData(
      polygon: (json['polygon'] as List<dynamic>? ?? [])
          .map(
            (point) => LatLng(
              (point['lat'] as num).toDouble(),
              (point['lng'] as num).toDouble(),
            ),
          )
          .toList(),
      jailLocation: LatLng(
        (json['jailLocation']['lat'] as num).toDouble(),
        (json['jailLocation']['lng'] as num).toDouble(),
      ),
      gameDurationSeconds: json['gameDurationSeconds'] as int? ?? 600,
      hideTimeSeconds: json['hideTimeSeconds'] as int? ?? 120,
      taskLevel: json['taskLevel'] as String? ?? '중',
      policeAbility: json['policeAbility'] as String? ?? '기본 추적',
    );
  }
}
