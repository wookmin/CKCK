import 'package:ckck_app/screens/home/home_page.dart';
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
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _CheckActionButton(
                  label: '이어폰 연결 확인',
                  checked: _earphonesChecked,
                  onPressed: () {
                    setState(() => _earphonesChecked = !_earphonesChecked);
                  },
                ),
                const SizedBox(height: 24),
                _CheckActionButton(
                  label: 'NFC 작동 확인',
                  checked: _nfcChecked,
                  onPressed: () {
                    setState(() => _nfcChecked = !_nfcChecked);
                  },
                ),
                const SizedBox(height: 140),
                SizedBox(
                  width: 140,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFD9D9D9),
                      foregroundColor: Colors.black,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute<void>(
                          builder: (_) => const HomePage(),
                        ),
                        (route) => false,
                      );
                    },
                    child: const Text(
                      '시작하기',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CheckActionButton extends StatelessWidget {
  const _CheckActionButton({
    required this.label,
    required this.checked,
    required this.onPressed,
  });

  final String label;
  final bool checked;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: checked ? const Color(0xFFBFC7CF) : const Color(0xFFD9D9D9),
          foregroundColor: Colors.black,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          checked ? '$label 완료' : label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
