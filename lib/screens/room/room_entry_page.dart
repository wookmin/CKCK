import 'package:ckck_app/providers/auth_provider.dart';
import 'package:ckck_app/providers/pending_room_provider.dart';
import 'package:ckck_app/providers/user_provider.dart';
import 'package:ckck_app/screens/auth/login_page.dart';
import 'package:ckck_app/screens/auth/post_login_check_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RoomEntryPage extends ConsumerStatefulWidget {
  const RoomEntryPage({
    super.key,
    required this.roomId,
  });

  final String roomId;

  @override
  ConsumerState<RoomEntryPage> createState() => _RoomEntryPageState();
}

class _RoomEntryPageState extends ConsumerState<RoomEntryPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(pendingRoomProvider.notifier).setPendingRoom(widget.roomId);
      await ref.read(userProvider.notifier).restore();
      final auth = await ref.read(authProvider.future);
      if (!mounted) {
        return;
      }

      final target = auth.isLoggedIn
          ? const PostLoginCheckPage()
          : const LoginPage();

      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => target),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
