import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class OverviewMetric extends StatelessWidget {
  final String title;
  final String value;
  final String change;
  final bool positive;

  const OverviewMetric({
    super.key,
    required this.title,
    required this.value,
    required this.change,
    required this.positive,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              Text(value, style: AppTextStyles.cardTitle),

              const SizedBox(width: 6),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),

                decoration: BoxDecoration(
                  color: (positive ? Colors.green : Colors.red).withOpacity(
                    .10,
                  ),

                  borderRadius: BorderRadius.circular(6),
                ),

                child: Text(
                  change,
                  style: AppTextStyles.caption.copyWith(
                    color: positive ? Colors.green : Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
