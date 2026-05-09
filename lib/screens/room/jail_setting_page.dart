import 'package:ckck_app/providers/room_provider.dart';
import 'package:ckck_app/screens/room/time_setting_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class JailSettingPage extends ConsumerStatefulWidget {
  const JailSettingPage({super.key});

  @override
  ConsumerState<JailSettingPage> createState() => _JailSettingPageState();
}

class _JailSettingPageState extends ConsumerState<JailSettingPage> {
  static const LatLng _fallbackCenter = LatLng(37.5665, 126.9780);
  static const Distance _distance = Distance();

  final MapController _mapController = MapController();
  LatLng _selectedCenter = _fallbackCenter;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadLocation();
  }

  Future<void> _loadLocation() async {
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        _finishLoading(_fallbackCenter);
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _finishLoading(_fallbackCenter);
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
      _selectedCenter = center;
      _loading = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
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
    final eastPoint = _distance.offset(_selectedCenter, 5, 90);
    final centerOffset = camera.getOffsetFromOrigin(_selectedCenter);
    final eastOffset = camera.getOffsetFromOrigin(eastPoint);
    final radius = (eastOffset - centerOffset).distance;
    return radius.clamp(18.0, 160.0);
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
                      '내 위치 주변 5m 범위가 감옥으로 지정됩니다.',
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
                            onPositionChanged: (camera, _) {
                              setState(() {
                                _selectedCenter = camera.center;
                              });
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
                          child: Builder(
                            builder: (context) {
                              final radius = _circleRadiusPx(_mapController.camera);

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
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        '내 위치',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Container(
                                        width: 38,
                                        height: 38,
                                        decoration: const BoxDecoration(
                                          color: Colors.black,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ],
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
                          ref
                              .read(roomProvider.notifier)
                              .setJailLocation(_selectedCenter);
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
