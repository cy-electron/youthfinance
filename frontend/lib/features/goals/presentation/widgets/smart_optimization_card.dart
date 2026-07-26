import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../design_system/cards/app_card.dart';

class SmartOptimizationCard extends StatelessWidget {
  const SmartOptimizationCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: const Color(0xff0F5C45),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.white12,
                child: Icon(Icons.auto_awesome, color: Colors.white),
              ),

              SizedBox(width: AppSpacing.md),

              Expanded(
                child: Text(
                  "Increase your MacBook contribution by ₹500/month to finish 23 days earlier.",
                  style: AppTextStyles.body.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),

          SizedBox(height: AppSpacing.lg),

          FilledButton(
            onPressed: () {},
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
            ),
            child: Text("Accept Recommendation"),
          ),
        ],
      ),
    );
  }
}
