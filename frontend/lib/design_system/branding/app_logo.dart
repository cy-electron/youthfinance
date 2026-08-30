import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;

  const AppLogo({super.key, this.size = 70});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/yf_logo.jpeg',
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}
