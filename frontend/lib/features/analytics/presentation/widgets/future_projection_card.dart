import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../design_system/cards/app_card.dart';

class FutureProjectionCard extends StatelessWidget {
  const FutureProjectionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: AppColors.primary,

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Where You're Headed",
            style: AppTextStyles.cardTitle.copyWith(color: Colors.white),
          ),

          const SizedBox(height: AppSpacing.sm),

          Text(
            "₹1.8L",
            style: AppTextStyles.heading.copyWith(
              color: Colors.white,
              fontSize: 42,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            "Estimated Savings by December 2026",
            style: AppTextStyles.body.copyWith(color: Colors.white70),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Padding was horizontal: 60 on each side, which left too
          // little room for the text and forced it to wrap onto a
          // second line. Reduced to 16, dropped maxLines to 1 (with
          // ellipsis as a safety net), and shrank the font slightly —
          // together this fits it on one line and takes up noticeably
          // less vertical space.
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 55, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Text(
              "Keep your current pace   •   On Track",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
