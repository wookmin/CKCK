import 'package:ckck_app/core/session/session_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _pendingRoomKey = 'pendingRoomId';

final pendingRoomProvider =
    NotifierProvider<PendingRoomNotifier, String?>(PendingRoomNotifier.new);

class PendingRoomNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  Future<void> restore() async {
    state = await ref.read(sessionStoreProvider).read(_pendingRoomKey);
  }

  Future<void> setPendingRoom(String roomId) async {
    state = roomId;
    await ref.read(sessionStoreProvider).write(_pendingRoomKey, roomId);
  }

  Future<void> clear() async {
    state = null;
    await ref.read(sessionStoreProvider).delete(_pendingRoomKey);
  }
}
