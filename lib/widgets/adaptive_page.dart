import 'package:flutter/material.dart';

class AppResponsive {
  const AppResponsive._(this.width);

  factory AppResponsive.of(BuildContext context) {
    return AppResponsive._(MediaQuery.sizeOf(context).width);
  }

  final double width;

  bool get isSmallPhone => width <= 375;
  bool get isPhone => width <= 430;
  bool get isTabletish => width <= 768;
  bool get useStackedActions => width <= 390;

  double get horizontalPadding {
    if (isSmallPhone) {
      return 16;
    }
    if (isPhone) {
      return 20;
    }
    if (isTabletish) {
      return 24;
    }
    return 32;
  }

  double get pageMaxWidth {
    if (isPhone) {
      return 420;
    }
    if (isTabletish) {
      return 500;
    }
    return 560;
  }

  double get primaryButtonMaxWidth => isSmallPhone ? double.infinity : 280;
  double get verticalGap => isSmallPhone ? 16 : 24;
  double get heroGap => isSmallPhone ? 64 : 88;
}

class AdaptivePage extends StatelessWidget {
  const AdaptivePage({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
    this.alignment = Alignment.center,
    this.scrollable = false,
  });

  final Widget child;
  final double? maxWidth;
  final EdgeInsetsGeometry? padding;
  final Alignment alignment;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final responsive = AppResponsive.of(context);
    final content = Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth ?? responsive.pageMaxWidth),
        child: child,
      ),
    );

    final padded = Padding(
      padding: padding ??
          EdgeInsets.symmetric(
            horizontal: responsive.horizontalPadding,
            vertical: responsive.isSmallPhone ? 20 : 28,
          ),
      child: content,
    );

    if (!scrollable) {
      return padded;
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: MediaQuery.sizeOf(context).height),
          child: padded,
        ),
      ),
    );
  }
}

class AdaptiveActionGroup extends StatelessWidget {
  const AdaptiveActionGroup({
    super.key,
    required this.children,
    this.spacing = 16,
  });

  final List<Widget> children;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final responsive = AppResponsive.of(context);
    if (responsive.useStackedActions) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var index = 0; index < children.length; index++) ...[
            children[index],
            if (index < children.length - 1) SizedBox(height: spacing),
          ],
        ],
      );
    }

    return Row(
      children: [
        for (var index = 0; index < children.length; index++) ...[
          Expanded(child: children[index]),
          if (index < children.length - 1) SizedBox(width: spacing),
        ],
      ],
    );
  }
}
