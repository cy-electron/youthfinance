import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;

  const AppLogo({
    super.key,
    this.size = 70,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'YouthFinance logo',
      image: true,
      child: SizedBox(
        width: size,
        height: size,
        child: Image.asset(
          'assets/images/yf_logo.png',
          width: size,
          height: size,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
          errorBuilder: (context, error, stackTrace) {
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}