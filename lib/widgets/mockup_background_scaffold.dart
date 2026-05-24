import 'package:flutter/material.dart';

class MockupBackgroundScaffold extends StatelessWidget {
  const MockupBackgroundScaffold({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/background.png', fit: BoxFit.cover),
          SafeArea(child: child),
        ],
      ),
    );
  }
}
