import 'package:flutter/material.dart';

import '../../../../design_system/branding/app_logo.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: const AppLogo(size: 280)));
  }
}
