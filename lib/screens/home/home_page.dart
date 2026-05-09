import 'package:ckck_app/providers/auth_provider.dart';
import 'package:ckck_app/providers/pending_room_provider.dart';
import 'package:ckck_app/providers/user_provider.dart';
import 'package:ckck_app/screens/auth/login_page.dart';
import 'package:ckck_app/screens/home/nickname_page.dart';
import 'package:ckck_app/widgets/adaptive_page.dart';
import 'package:ckck_app/widgets/app_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  static const routeName = '/home';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final responsive = AppResponsive.of(context);
    return Scaffold(
      body: AdaptivePage(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AppLogo(showSubtitle: false),
            SizedBox(height: responsive.heroGap),
            _MockupActionButton(
              label: '방 생성하기',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const NicknamePage(isHost: true),
                  ),
                );
              },
            ),
            SizedBox(height: responsive.verticalGap),
            _MockupActionButton(
              label: '방 참여하기',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const NicknamePage(isHost: false),
                  ),
                );
              },
            ),
            SizedBox(height: responsive.heroGap * 0.7),
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
                  onPressed: () async {
                    await ref.read(authProvider.notifier).logout();
                    await ref.read(userProvider.notifier).clear();
                    await ref.read(pendingRoomProvider.notifier).clear();
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
                  child: const Text(
                    '로그아웃',
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

class _MockupActionButton extends StatelessWidget {
  const _MockupActionButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFFD9D9D9),
          foregroundColor: Colors.black,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
        ).copyWith(
          minimumSize: WidgetStatePropertyAll(
            Size(
              0,
              MediaQuery.sizeOf(context).width < 390 ? 52 : 56,
            ),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
