import 'package:ckck_app/providers/auth_provider.dart';
import 'package:ckck_app/screens/auth/login_page.dart';
import 'package:ckck_app/screens/home/join_room_page.dart';
import 'package:ckck_app/screens/home/nickname_page.dart';
import 'package:ckck_app/widgets/mockup_background_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  static const routeName = '/home';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MockupBackgroundScaffold(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () async {
                      await ref.read(authProvider.notifier).logout();
                      if (!context.mounted) {
                        return;
                      }
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute<void>(
                          builder: (_) => const LoginPage(),
                        ),
                        (route) => false,
                      );
                    },
                    child: Image.asset(
                      'assets/logoutBtn.png',
                      width: 56,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                SizedBox(height: constraints.maxHeight * 0.2),
                _MockupAssetButton(
                  assetPath: 'assets/createRoom.png',
                  width: constraints.maxWidth * 0.82,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const NicknamePage(isHost: true),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                _MockupAssetButton(
                  assetPath: 'assets/enterRoom.png',
                  width: constraints.maxWidth * 0.82,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const JoinRoomPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MockupAssetButton extends StatelessWidget {
  const _MockupAssetButton({
    required this.assetPath,
    required this.onTap,
    required this.width,
  });

  final String assetPath;
  final VoidCallback onTap;
  final double width;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Image.asset(
        assetPath,
        width: width,
        fit: BoxFit.contain,
      ),
    );
  }
}
