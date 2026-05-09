import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.compact = false,
    this.showSubtitle = true,
  });

  static const String assetPath = 'assets/로고Y 1.png';

  final bool compact;
  final bool showSubtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final logoWidth = compact
        ? (screenWidth < 360 ? 128.0 : 150.0)
        : (screenWidth < 360 ? 172.0 : 210.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          assetPath,
          width: logoWidth,
          fit: BoxFit.contain,
        ),
        if (showSubtitle) ...[
          const SizedBox(height: 12),
          Text(
            'GPS 술래잡기',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: const Color(0xFF475569),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}
