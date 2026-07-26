import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import 'app_card.dart';

class SummaryCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;

  final String title;
  final String value;

  final String? change;

  final Color? changeColor;

  final bool showProgress;

  final double progress;

  const SummaryCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    this.change,
    this.changeColor,
    this.showProgress = false,
    this.progress = 0,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: iconColor.withValues(alpha: .12),
            child: Icon(icon, color: iconColor),
          ),

          const SizedBox(height: AppSpacing.md),

          Text(title, style: AppTextStyles.caption),

          const SizedBox(height: 6),

          Text(value, style: AppTextStyles.cardTitle),

          const Spacer(),

          if (change != null)
            Text(
              change!,
              style: TextStyle(color: changeColor, fontWeight: FontWeight.w600),
            ),

          if (showProgress) ...[
            const SizedBox(height: 8),

            ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: Colors.grey.shade200,
                color: AppColors.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
