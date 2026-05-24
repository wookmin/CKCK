import 'package:ckck_app/screens/home/home_page.dart';
import 'package:ckck_app/widgets/mockup_background_scaffold.dart';
import 'package:flutter/material.dart';

class PostLoginCheckPage extends StatefulWidget {
  const PostLoginCheckPage({super.key});

  @override
  State<PostLoginCheckPage> createState() => _PostLoginCheckPageState();
}

class _PostLoginCheckPageState extends State<PostLoginCheckPage> {
  bool _earphonesChecked = false;
  bool _nfcChecked = false;

  @override
  Widget build(BuildContext context) {
    return MockupBackgroundScaffold(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: Image.asset('assets/logoutBtn.png', width: 56),
                    ),
                    SizedBox(height: constraints.maxHeight * 0.01),
                    Image.asset(
                      'assets/prepareBubble.png',
                      width: constraints.maxWidth * 0.7,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: constraints.maxHeight * 0.005),
                    _CheckAssetButton(
                      assetPath: 'assets/airpodcheck.png',
                      width: constraints.maxWidth * 0.84,
                      checked: _earphonesChecked,
                      onTap: () {
                        setState(() => _earphonesChecked = !_earphonesChecked);
                      },
                    ),
                    const SizedBox(height: 18),
                    _CheckAssetButton(
                      assetPath: 'assets/nfcCheck.png',
                      width: constraints.maxWidth * 0.84,
                      checked: _nfcChecked,
                      onTap: () {
                        setState(() => _nfcChecked = !_nfcChecked);
                      },
                    ),
                    SizedBox(height: constraints.maxHeight * 0.1),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute<void>(
                            builder: (_) => const HomePage(),
                          ),
                          (route) => false,
                        );
                      },
                      child: Image.asset(
                        'assets/succeedBtn.png',
                        width: 100,
                        fit: BoxFit.contain,
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

class _CheckAssetButton extends StatelessWidget {
  const _CheckAssetButton({
    required this.assetPath,
    required this.width,
    required this.checked,
    required this.onTap,
  });

  final String assetPath;
  final double width;
  final bool checked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(assetPath, width: width, fit: BoxFit.fitWidth),
          if (checked)
            Positioned(
              top: 8,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFC400),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.black, width: 2),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check, size: 14, color: Colors.black),
                    SizedBox(width: 4),
                    Text(
                      '완료',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
