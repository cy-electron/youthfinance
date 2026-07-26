import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class AppIconButton extends StatelessWidget {
  final IconData icon;

  final VoidCallback onTap;

  const AppIconButton({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(100),

      onTap: onTap,

      child: Container(
        width: 48,
        height: 48,

        decoration: const BoxDecoration(
          color: Colors.white,

          shape: BoxShape.circle,
        ),

        child: Icon(icon, color: AppColors.textPrimary),
      ),
    );
  }
}
