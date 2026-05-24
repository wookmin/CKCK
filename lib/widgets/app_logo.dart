import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.compact = false, this.showSubtitle = true});

  static const String assetPath = 'assets/logo.png';

  final bool compact;
  final bool showSubtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(assetPath, width: compact ? 150 : 210, fit: BoxFit.contain),
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
