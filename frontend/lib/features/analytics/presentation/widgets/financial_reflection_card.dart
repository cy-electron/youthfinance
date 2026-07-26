import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../design_system/cards/app_card.dart';

class FinancialReflectionCard extends StatelessWidget {
  const FinancialReflectionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          const Icon(Icons.favorite_outline, size: 34),

          const SizedBox(height: AppSpacing.sm),

          Text(
            "Money is a tool,\nnot a measure of your worth.",
            textAlign: TextAlign.center,
            style: AppTextStyles.cardTitle,
          ),

          const SizedBox(height: 8),

          Text(
            "Save, Spend and Grow at your own pace.",
            textAlign: TextAlign.center,
            style: AppTextStyles.body,
          ),
        ],
      ),
    );
  }
}
