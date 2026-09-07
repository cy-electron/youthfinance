import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';

class HealthMetric extends StatelessWidget {
  final IconData icon;
  final String title;
  final String status;
  final double progress;
  final Color color;

  const HealthMetric({
    super.key,
    required this.icon,
    required this.title,
    required this.status,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final safeProgress = progress.clamp(0.0, 1.0);

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          SizedBox(
            height: 24,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Icon(
                icon,
                size: 22,
                color: color,
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Title
          SizedBox(
            height: 18,
            child: Text(
              title,
              style: AppTextStyles.caption,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(height: 3),

          // Fixed-height status area.
          // Keeps all four indicators identical in height.
          SizedBox(
            height: 28,
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                status,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: color,
                  height: 1.15,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Progress bar
          SizedBox(
            height: 6,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: LinearProgressIndicator(
                value: safeProgress,
                minHeight: 6,
                backgroundColor: const Color(0xFFECECEC),
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}