import 'package:ckck_app/providers/room_provider.dart';
import 'package:ckck_app/screens/room/lobby_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class JoinRoomPage extends ConsumerStatefulWidget {
  const JoinRoomPage({super.key});

  @override
  ConsumerState<JoinRoomPage> createState() => _JoinRoomPageState();
}

class _JoinRoomPageState extends ConsumerState<JoinRoomPage> {
  final _roomController = TextEditingController();
  bool _joining = false;
  bool _showQrScanner = false;

  @override
  void dispose() {
    _roomController.dispose();
    super.dispose();
  }

  Future<void> _joinRoom(String rawRoomId) async {
    if (_joining) {
      return;
    }
    final roomId = rawRoomId.trim().split('/').last;
    if (roomId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('방 코드 또는 링크를 입력해 주세요.')),
      );
      return;
    }

    setState(() => _joining = true);

    try {
      final repository = ref.read(roomRepositoryProvider);
      await repository.joinRoom(roomId);
      final room = await repository.getRoom(roomId);
      ref.read(roomProvider.notifier).hydrateFromRoomData(room, roomId: roomId);

      if (!mounted) {
        return;
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => LobbyPage(roomId: roomId)),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString().replaceFirst('Exception: ', '')),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _joining = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '참여 코드를 입력해 주세요',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 88),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  color: const Color(0xFFD9D9D9),
                  child: TextField(
                    controller: _roomController,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: '참여 코드 :',
                      hintStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                      ),
                    ),
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 44),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () {
                      setState(() => _showQrScanner = !_showQrScanner);
                    },
                    icon: Icon(
                      _showQrScanner
                          ? Icons.close_rounded
                          : Icons.qr_code_scanner_rounded,
                      color: Colors.black87,
                    ),
                    label: Text(
                      _showQrScanner ? 'QR 닫기' : 'QR 스캔',
                      style: const TextStyle(color: Colors.black87),
                    ),
                  ),
                ),
                if (_showQrScanner) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 280,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: MobileScanner(
                        controller: MobileScannerController(
                          detectionSpeed: DetectionSpeed.noDuplicates,
                        ),
                        onDetect: (capture) {
                          final value = capture.barcodes.isNotEmpty
                              ? capture.barcodes.first.rawValue
                              : null;
                          if (value != null && value.isNotEmpty) {
                            _joinRoom(value);
                          }
                        },
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 72),
                Center(
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
                      onPressed:
                          _joining ? null : () => _joinRoom(_roomController.text),
                      child: _joining
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(
                              '완료',
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
        ),
      ),
    );
  }
}
