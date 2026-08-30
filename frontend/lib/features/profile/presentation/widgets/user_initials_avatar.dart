import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class UserInitialsAvatar extends StatelessWidget {
  final String fullName;
  final double radius;

  const UserInitialsAvatar({
    super.key,
    required this.fullName,
    this.radius = 24,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primaryLight,
      child: Text(
        _getInitials(fullName),
        style: AppTextStyles.cardTitle.copyWith(
          color: AppColors.primary,
          fontSize: radius * 0.65,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) {
      return "?";
    }

    if (parts.length == 1) {
      final first = parts.first;

      if (first.length >= 2) {
        return first.substring(0, 2).toUpperCase();
      }

      return first.substring(0, 1).toUpperCase();
    }

    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }
}
