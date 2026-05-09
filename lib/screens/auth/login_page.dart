import 'package:ckck_app/providers/auth_provider.dart';
import 'package:ckck_app/screens/auth/post_login_check_page.dart';
import 'package:ckck_app/widgets/adaptive_page.dart';
import 'package:ckck_app/widgets/app_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  static const routeName = '/login';

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  Future<void> _submit() async {
    await ref.read(authProvider.notifier).login('google_mock_user', '1234');

    if (!mounted) {
      return;
    }

    final auth = ref.read(authProvider);
    final loggedIn = auth.valueOrNull?.isLoggedIn ?? false;

    if (loggedIn) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => const PostLoginCheckPage(),
        ),
      );
      return;
    }

    auth.whenOrNull(
      error: (error, _) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString().replaceFirst('Exception: ', '')),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final responsive = AppResponsive.of(context);

    return Scaffold(
      body: AdaptivePage(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AppLogo(showSubtitle: false),
            SizedBox(height: responsive.heroGap),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: responsive.primaryButtonMaxWidth),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFD9D9D9),
                    foregroundColor: Colors.black,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0),
                    ),
                  ),
                  onPressed: authState.isLoading ? null : _submit,
                  icon: authState.isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.login_rounded),
                  label: const Text(
                    '구글 로그인',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              '웹 프로토타입은 로그인 후 모바일 브라우저 흐름에 맞춰 진행됩니다.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF475569),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
