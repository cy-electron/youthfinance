import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class HealthMetric extends StatelessWidget {
  final IconData icon;
  final String title;
  final String status;
  final double progress;

  const HealthMetric({
    super.key,
    required this.icon,
    required this.title,
    required this.status,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: AppColors.primary),

          const SizedBox(height: 8),

          Text(
            title,
            style: AppTextStyles.caption,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 2),

          Text(
            status,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 10),

          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: Color(0xffECECEC),
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
