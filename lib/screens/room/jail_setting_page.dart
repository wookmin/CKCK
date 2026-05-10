import 'dart:math' as math;

import 'package:ckck_app/providers/room_provider.dart';
import 'package:ckck_app/screens/room/time_setting_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

class JailSettingPage extends ConsumerStatefulWidget {
  const JailSettingPage({super.key});

  @override
  ConsumerState<JailSettingPage> createState() => _JailSettingPageState();
}

class _JailSettingPageState extends ConsumerState<JailSettingPage> {
  static const LatLng _fallbackCenter = LatLng(37.5665, 126.9780);
  static const Distance _distance = Distance();
  static const double _fallbackCircleRadiusPx = 24;

  final MapController _mapController = MapController();
  LatLng _selectedCenter = _fallbackCenter;
  List<LatLng> _gamePolygonPoints = const [];
  LatLngBounds? _gameBounds;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialSelection();
  }

  void _loadInitialSelection() {
    final room = ref.read(roomProvider);
    _gamePolygonPoints = room.polygonPoints;
    _gameBounds = _gamePolygonPoints.length >= 4
        ? LatLngBounds.fromPoints(_gamePolygonPoints)
        : null;

    final initialCenter = _gameBounds == null
        ? _fallbackCenter
        : LatLng(
            (_gameBounds!.north + _gameBounds!.south) / 2,
            (_gameBounds!.east + _gameBounds!.west) / 2,
          );
    _finishLoading(initialCenter);
  }

  LatLng _clampToBounds(LatLng point) {
    final bounds = _gameBounds;
    if (bounds == null) {
      return point;
    }

    return LatLng(
      point.latitude.clamp(bounds.south, bounds.north),
      point.longitude.clamp(bounds.west, bounds.east),
    );
  }

  bool _isInsideBounds(LatLng point) {
    final bounds = _gameBounds;
    if (bounds == null) {
      return true;
    }

    return point.latitude >= bounds.south &&
        point.latitude <= bounds.north &&
        point.longitude >= bounds.west &&
        point.longitude <= bounds.east;
  }

  void _finishLoading(LatLng center) {
    if (!mounted) {
      return;
    }

    setState(() {
      _selectedCenter = center;
      _loading = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final bounds = _gameBounds;
      if (bounds != null) {
        _mapController.fitCamera(
          CameraFit.bounds(
            bounds: bounds,
            padding: const EdgeInsets.all(36),
            maxZoom: 18,
          ),
        );
        return;
      }
      _mapController.move(center, 18);
    });
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      centerTitle: true,
      title: const Text(
        '감옥 범위 설정',
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
      ),
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
      scrolledUnderElevation: 0,
    );
  }

  double _circleRadiusPx(MapCamera camera) {
    final mapSize = camera.nonRotatedSize;
    if (!mapSize.width.isFinite ||
        !mapSize.height.isFinite ||
        mapSize.width <= 0 ||
        mapSize.height <= 0) {
      return _fallbackCircleRadiusPx;
    }

    final eastPoint = _distance.offset(_selectedCenter, 5, 90);
    final centerOffset = camera.getOffsetFromOrigin(_selectedCenter);
    final eastOffset = camera.getOffsetFromOrigin(eastPoint);
    final radius = (eastOffset - centerOffset).distance;
    if (!radius.isFinite || radius <= 0) {
      return _fallbackCircleRadiusPx;
    }

    return math.max(radius, 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Container(
                    color: const Color(0xFFD9D9D9),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: const Text(
                      '중앙 점 주변 5m 범위가 감옥으로 지정됩니다.',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Expanded(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        FlutterMap(
                          mapController: _mapController,
                          options: MapOptions(
                            initialCenter: _selectedCenter,
                            initialZoom: 18,
                            cameraConstraint: _gameBounds == null
                                ? const CameraConstraint.unconstrained()
                                : CameraConstraint.containCenter(
                                    bounds: _gameBounds!,
                                  ),
                            onPositionChanged: (camera, _) {
                              setState(() {
                                _selectedCenter = _clampToBounds(camera.center);
                              });
                            },
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.example.ckck',
                            ),
                            if (_gamePolygonPoints.isNotEmpty)
                              PolygonLayer(
                                polygons: [
                                  Polygon(
                                    points: _gamePolygonPoints,
                                    color: const Color(0x14FF3B30),
                                    borderColor: const Color(0xFFFF3B30),
                                    borderStrokeWidth: 3,
                                  ),
                                ],
                              ),
                          ],
                        ),
                        IgnorePointer(
                            child: Builder(
                            builder: (context) {
                              final radius = _circleRadiusPx(
                                _mapController.camera,
                              );

                              return Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width: radius * 2,
                                    height: radius * 2,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: const Color(0x26FF6B6B),
                                      border: Border.all(
                                        color: Colors.red,
                                        width: 1.4,
                                      ),
                                    ),
                                  ),
                                  Transform.translate(
                                    offset: Offset(0, -(radius + 28)),
                                    child: const Text(
                                      '감옥 위치',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(24, 28, 24, 18),
                    child: Text(
                      '감옥으로 지정할 위치로 이동 후\n지정 버튼을 눌러 주세요 !',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 32),
                    child: SizedBox(
                      width: 96,
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
                          final jailCenter = _clampToBounds(_selectedCenter);
                          if (!_isInsideBounds(jailCenter)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('감옥 위치는 게임 범위 안에서만 지정할 수 있어요.'),
                              ),
                            );
                            return;
                          }
                          ref
                              .read(roomProvider.notifier)
                              .setJailLocation(jailCenter);
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const TimeSettingPage(),
                            ),
                          );
                        },
                        child: const Text(
                          '지정',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
