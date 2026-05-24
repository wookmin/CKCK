import 'package:ckck_app/providers/auth_provider.dart';
import 'package:ckck_app/screens/auth/post_login_check_page.dart';
import 'package:ckck_app/widgets/mockup_background_scaffold.dart';
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
        MaterialPageRoute<void>(builder: (_) => const PostLoginCheckPage()),
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

    return MockupBackgroundScaffold(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    SizedBox(height: constraints.maxHeight * 0.22),
                    Image.asset(
                      'assets/logo.png',
                      width: 240,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: constraints.maxHeight * 0.18),
                    GestureDetector(
                      onTap: authState.isLoading ? null : _submit,
                      behavior: HitTestBehavior.opaque,
                      child: SizedBox(
                        width: 280,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Opacity(
                              opacity: authState.isLoading ? 0.7 : 1,
                              child: Image.asset(
                                'assets/googleLogin.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                            if (authState.isLoading)
                              const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.black,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
