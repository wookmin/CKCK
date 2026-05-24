import 'package:flutter/material.dart';

class RoomSettingMockupHeader extends StatelessWidget {
  const RoomSettingMockupHeader({
    super.key,
    required this.title,
    required this.onBack,
  });

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;

    return Container(
      color: const Color(0xFFFFC400),
      padding: EdgeInsets.only(top: topPadding + 12, left: 16, right: 16, bottom: 18),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.black,
                size: 28,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }
}

PreferredSizeWidget buildRoomSettingAppBar({
  required BuildContext context,
  required String title,
}) {
  return AppBar(
    centerTitle: true,
    title: Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.w800,
        fontSize: 20,
        color: Colors.black,
      ),
    ),
    backgroundColor: const Color(0xFFFFF4BF),
    foregroundColor: Colors.black,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 0,
    bottom: const PreferredSize(
      preferredSize: Size.fromHeight(3),
      child: Divider(
        height: 3,
        thickness: 3,
        color: Colors.black,
      ),
    ),
  );
}

class RoomSettingBackground extends StatelessWidget {
  const RoomSettingBackground({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/background.png',
          fit: BoxFit.cover,
        ),
        child,
      ],
    );
  }
}

class RoomSettingInfoCard extends StatelessWidget {
  const RoomSettingInfoCard({
    super.key,
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFAEC),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.black, width: 3),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            offset: Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 15,
          height: 1.35,
          fontWeight: FontWeight.w800,
          color: Colors.black,
        ),
      ),
    );
  }
}

class RoomSettingMapFrame extends StatelessWidget {
  const RoomSettingMapFrame({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.black, width: 3),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            offset: Offset(0, 6),
            blurRadius: 0,
          ),
        ],
      ),
      child: child,
    );
  }
}

class RoomSettingActionButton extends StatelessWidget {
  const RoomSettingActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isPrimary = true,
    this.isBusy = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: isPrimary
            ? const Color(0xFFFFC400)
            : const Color(0xFFFFF4BF),
        foregroundColor: Colors.black,
        disabledBackgroundColor: const Color(0xFFE3D9A6),
        disabledForegroundColor: Colors.black54,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Colors.black, width: 3),
        ),
      ),
      onPressed: isBusy ? null : onPressed,
      child: isBusy
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Colors.black,
              ),
            )
          : Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),
    );
  }
}

class RoomSettingValueCard extends StatelessWidget {
  const RoomSettingValueCard({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFAEC),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black, width: 3),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            offset: Offset(0, 5),
            blurRadius: 0,
          ),
        ],
      ),
      child: child,
    );
  }
}
