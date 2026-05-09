import 'package:ckck_app/core/routing/app_routes.dart';
import 'package:ckck_app/providers/auth_provider.dart';
import 'package:ckck_app/providers/pending_room_provider.dart';
import 'package:ckck_app/providers/user_provider.dart';
import 'package:ckck_app/screens/auth/login_page.dart';
import 'package:ckck_app/screens/home/home_page.dart';
import 'package:ckck_app/screens/room/room_entry_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

class CkckApp extends StatelessWidget {
  const CkckApp({super.key});

  @override
  Widget build(BuildContext context) {
    final initialRoute = WidgetsBinding.instance.platformDispatcher.defaultRouteName;
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
      initialRoute: initialRoute.isEmpty ? AppRoutes.root : initialRoute,
      onGenerateRoute: (settings) {
        final routeName = settings.name ?? AppRoutes.root;
        final roomId = AppRoutes.parseRoomId(routeName);
        if (roomId != null) {
          return MaterialPageRoute<void>(
            settings: settings,
            builder: (_) => RoomEntryPage(roomId: roomId),
          );
        }

        switch (routeName) {
          case AppRoutes.root:
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (_) => const _InitialRouteGate(),
            );
          case AppRoutes.login:
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (_) => const LoginPage(),
            );
          case AppRoutes.home:
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (_) => const HomePage(),
            );
          default:
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (_) => const _InitialRouteGate(),
            );
        }
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
    await ref.read(userProvider.notifier).restore();
    await ref.read(pendingRoomProvider.notifier).restore();

    if (!mounted) {
      return;
    }

    setState(() {
      _initialPage = auth.isLoggedIn
          ? const HomePage()
          : const LoginPage();
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
