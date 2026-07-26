import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:youthfinance/core/theme/app_text_styles.dart';
import 'package:youthfinance/design_system/cards/app_card.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class GoalSummaryCard extends StatelessWidget {
  const GoalSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    const progress = 0.42;

    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircularPercentIndicator(
            radius: 52,
            lineWidth: 10,
            percent: progress,
            circularStrokeCap: CircularStrokeCap.round,
            animation: true,
            animationDuration: 900,
            progressColor: AppColors.primary,
            backgroundColor: AppColors.primary.withOpacity(.10),
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "42%",
                  style: AppTextStyles.heading.copyWith(
                    fontSize: 28,
                    height: 1,
                  ),
                ),
                Text("Overall", style: AppTextStyles.caption),
              ],
            ),
          ),

          const SizedBox(width: AppSpacing.lg),

          // ACTIVE + SAVED sit side by side in a row, with TOTAL TARGET
          // as its own full-width row below — was a single stacked
          // Column of all three, which doesn't match the 2-column +
          // 1-row layout in the design.
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _SummaryItem(title: "ACTIVE", value: "3"),
                    ),
                    Expanded(
                      child: _SummaryItem(title: "SAVED", value: "₹58K"),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.md),

                // Only this value is colored (matches the design, where
                // ACTIVE/SAVED values are dark/neutral and only TOTAL
                // TARGET is highlighted in green).
                _SummaryItem(
                  title: "TOTAL TARGET",
                  value: "₹140K",
                  valueColor: AppColors.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String title;
  final String value;
  final Color? valueColor;

  const _SummaryItem({
    required this.title,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.sectionTitle.copyWith(
            color: AppColors.textSecondary,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          value,
          style: AppTextStyles.cardTitle.copyWith(
            fontSize: 22,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
