import 'package:ckck_app/providers/room_provider.dart';
import 'package:ckck_app/screens/room/jail_setting_page.dart';
import 'package:ckck_app/widgets/room_setting_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class RangeSettingPage extends ConsumerStatefulWidget {
  const RangeSettingPage({super.key});

  @override
  ConsumerState<RangeSettingPage> createState() => _RangeSettingPageState();
}

class _RangeSettingPageState extends ConsumerState<RangeSettingPage> {
  static const LatLng _fallbackCenter = LatLng(37.5665, 126.9780);

  final MapController _mapController = MapController();
  LatLng _initialCenter = _fallbackCenter;
  Size? _mapViewportSize;
  double _zoom = 16;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadLocation();
  }

  Future<void> _loadLocation() async {
    final room = ref.read(roomProvider);

    try {
      final savedCenter = room.polygonPoints.isNotEmpty
          ? _getPolygonCenter(room.polygonPoints)
          : null;

      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        _finishLoading(savedCenter ?? _fallbackCenter);
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _finishLoading(savedCenter ?? _fallbackCenter);
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      _finishLoading(LatLng(position.latitude, position.longitude));
    } catch (_) {
      _finishLoading(_fallbackCenter);
    }
  }

  void _finishLoading(LatLng center) {
    if (!mounted) {
      return;
    }

    setState(() {
      _initialCenter = center;
      _loading = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _mapController.move(center, _zoom);
    });
  }

  LatLng _getPolygonCenter(List<LatLng> points) {
    final lat =
        points.map((point) => point.latitude).reduce((a, b) => a + b) /
        points.length;
    final lng =
        points.map((point) => point.longitude).reduce((a, b) => a + b) /
        points.length;
    return LatLng(lat, lng);
  }

  Rect _selectionRect(Size size) {
    final width = size.width * 0.78;
    final height = size.height * 0.52;
    final left = (size.width - width) / 2;
    final top = size.height * 0.17;
    return Rect.fromLTWH(left, top, width, height);
  }

  void _resetSelection() {
    ref.read(roomProvider.notifier).clearPolygon();
    _mapController.move(_initialCenter, _zoom);
  }

  void _confirmSelection(Size size) {
    final camera = _mapController.camera;
    final rect = _selectionRect(size);
    final points = <LatLng>[
      camera.offsetToCrs(rect.topLeft),
      camera.offsetToCrs(rect.topRight),
      camera.offsetToCrs(rect.bottomRight),
      camera.offsetToCrs(rect.bottomLeft),
    ];

    ref.read(roomProvider.notifier).setPolygonPoints(points);

    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const JailSettingPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildRoomSettingAppBar(
        context: context,
        title: '게임 범위 설정',
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RoomSettingBackground(
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
                  child: Column(
                    children: [
                      const RoomSettingInfoCard(
                        text: '지도를 움직여 게임 범위를 설정해 주세요.',
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final size = Size(
                              constraints.maxWidth,
                              constraints.maxHeight,
                            );
                            _mapViewportSize = size;
                            final rect = _selectionRect(size);

                            return RoomSettingMapFrame(
                              child: Stack(
                                children: [
                                  FlutterMap(
                                    mapController: _mapController,
                                    options: MapOptions(
                                      initialCenter: _initialCenter,
                                      initialZoom: _zoom,
                                      onPositionChanged: (camera, _) {
                                        _zoom = camera.zoom;
                                      },
                                    ),
                                    children: [
                                      TileLayer(
                                        urlTemplate:
                                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                        userAgentPackageName: 'com.example.ckck',
                                      ),
                                    ],
                                  ),
                                  IgnorePointer(
                                    child: Stack(
                                      children: [
                                        Positioned.fill(
                                          child: CustomPaint(
                                            painter: _SelectionMaskPainter(rect),
                                          ),
                                        ),
                                        Positioned.fromRect(
                                          rect: rect,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Colors.red,
                                                width: 2,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 22, 14, 0),
                        child: Row(
                          children: [
                            Expanded(
                              child: RoomSettingActionButton(
                                label: '복원',
                                onPressed: _resetSelection,
                                isPrimary: false,
                              ),
                            ),
                            const SizedBox(width: 18),
                            Expanded(
                              child: RoomSettingActionButton(
                                label: '확인',
                                onPressed: () {
                                  final size = _mapViewportSize;
                                  if (size == null) {
                                    return;
                                  }
                                  _confirmSelection(size);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

class _SelectionMaskPainter extends CustomPainter {
  const _SelectionMaskPainter(this.selectionRect);

  final Rect selectionRect;

  @override
  void paint(Canvas canvas, Size size) {
    final overlayPaint = Paint()..color = const Color(0x99FFFFFF);
    final clearPaint = Paint()..blendMode = BlendMode.clear;

    canvas.saveLayer(Offset.zero & size, Paint());
    canvas.drawRect(Offset.zero & size, overlayPaint);
    canvas.drawRect(selectionRect, clearPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SelectionMaskPainter oldDelegate) {
    return oldDelegate.selectionRect != selectionRect;
  }
}
