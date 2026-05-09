import 'package:ckck_app/providers/room_provider.dart';
import 'package:ckck_app/providers/pending_room_provider.dart';
import 'package:ckck_app/screens/room/lobby_page.dart';
import 'package:ckck_app/widgets/adaptive_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class JoinRoomPage extends ConsumerStatefulWidget {
  const JoinRoomPage({
    super.key,
    this.initialRoomValue,
    this.autoJoinOnInit = false,
  });

  final String? initialRoomValue;
  final bool autoJoinOnInit;

  @override
  ConsumerState<JoinRoomPage> createState() => _JoinRoomPageState();
}

class _JoinRoomPageState extends ConsumerState<JoinRoomPage> {
  final _roomController = TextEditingController();
  bool _joining = false;
  bool _showQrScanner = false;

  @override
  void initState() {
    super.initState();
    _roomController.text = widget.initialRoomValue ?? '';
    if (widget.autoJoinOnInit && (widget.initialRoomValue?.isNotEmpty ?? false)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _joinRoom(widget.initialRoomValue!);
      });
    }
  }

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
      await ref.read(pendingRoomProvider.notifier).clear();

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
    final responsive = AppResponsive.of(context);
    final showScanner = _showQrScanner && !kIsWeb;

    return Scaffold(
      body: AdaptivePage(
        scrollable: true,
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
            SizedBox(height: responsive.heroGap),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              color: const Color(0xFFD9D9D9),
              child: TextField(
                controller: _roomController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: '참여 코드 또는 링크 붙여넣기',
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
            const SizedBox(height: 16),
            Text(
              kIsWeb
                  ? '웹 프로토타입에서는 방 링크를 붙여넣거나 참여 코드를 직접 입력해 주세요.'
                  : '참여 코드를 입력하거나 QR로 빠르게 들어갈 수 있어요.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF475569),
                  ),
            ),
            const SizedBox(height: 28),
            if (!kIsWeb)
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
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                color: const Color(0xFFF1F5F9),
                child: const Text(
                  'QR 스캔은 모바일 앱에서 지원 예정입니다.',
                  style: TextStyle(color: Color(0xFF475569)),
                ),
              ),
            if (showScanner) ...[
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
            SizedBox(height: responsive.heroGap),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: responsive.primaryButtonMaxWidth),
              child: SizedBox(
                width: double.infinity,
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
                  onPressed: _joining ? null : () => _joinRoom(_roomController.text),
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
    );
  }
}
