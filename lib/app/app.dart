import 'package:ckck_app/providers/auth_provider.dart';
import 'package:ckck_app/screens/auth/login_page.dart';
import 'package:ckck_app/screens/home/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

class CkckApp extends StatelessWidget {
  const CkckApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: rootNavigatorKey,
      title: 'CKCK',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0E7490),
          primary: const Color(0xFF0F766E),
          secondary: const Color(0xFFF97316),
          surface: const Color(0xFFF8FAFC),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
        ),
      ),
      home: const _InitialRouteGate(),
      routes: {
        HomePage.routeName: (_) => const HomePage(),
      },
    );
  }
}

class _InitialRouteGate extends ConsumerStatefulWidget {
  const _InitialRouteGate();

  @override
  ConsumerState<_InitialRouteGate> createState() => _InitialRouteGateState();
}

class _InitialRouteGateState extends ConsumerState<_InitialRouteGate> {
  Widget? _initialPage;

  @override
  void initState() {
    super.initState();
    _resolveInitialPage();
  }

  Future<void> _resolveInitialPage() async {
    final auth = await ref.read(authProvider.future);

    if (!mounted) {
      return;
    }

    setState(() {
      _initialPage = auth.isLoggedIn ? const HomePage() : const LoginPage();
    });
  }

  @override
  Widget build(BuildContext context) {
    return _initialPage ?? const _AppLoadingPage();
  }
}

class _AppLoadingPage extends StatelessWidget {
  const _AppLoadingPage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
