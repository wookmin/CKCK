import 'dart:math' as math;

import 'package:ckck_app/providers/room_provider.dart';
import 'package:ckck_app/screens/room/time_setting_page.dart';
import 'package:ckck_app/widgets/room_setting_ui.dart';
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
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                RoomSettingMockupHeader(
                  title: '감옥 범위 설정',
                  onBack: () => Navigator.of(context).pop(),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Stack(
                        children: [
                          Positioned.fill(
                            child: FlutterMap(
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
                                    _selectedCenter = _clampToBounds(
                                      camera.center,
                                    );
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
                          ),
                          Positioned(
                            top: 18,
                            left: 10,
                            right: 10,
                            child: Center(
                              child: Image.asset(
                                'assets/mockups/setLocationBubble.png',
                                width: constraints.maxWidth * 0.92,
                                fit: BoxFit.contain,
                              ),
                            ),
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
                                        color: const Color(0x18FF6B6B),
                                        border: Border.all(
                                          color: const Color(0xFFFF4A4A),
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                    Image.asset(
                                      'assets/mockups/jailMarker.png',
                                      width: 62,
                                      fit: BoxFit.contain,
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 22,
                            child: Center(
                              child: GestureDetector(
                                onTap: () {
                                  final jailCenter = _clampToBounds(
                                    _selectedCenter,
                                  );
                                  if (!_isInsideBounds(jailCenter)) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          '감옥 위치는 게임 범위 안에서만 지정할 수 있어요.',
                                        ),
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
                                child: Image.asset(
                                  'assets/mockups/setLocationBtn.png',
                                  width: 100,
                                  fit: BoxFit.contain,
                                ),
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
    );
  }
}
