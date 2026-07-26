import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class SectionHeader extends StatelessWidget {
  final String title;

  final String? actionText;

  final VoidCallback? onPressed;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionText,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title.toUpperCase(), style: AppTextStyles.sectionTitle),

        const Spacer(),

        if (actionText != null)
          GestureDetector(
            onTap: onPressed,

            child: Text(
              actionText!,

              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}
