import 'package:flutter/material.dart';

import '../../model/goal_model.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../design_system/cards/app_card.dart';

class GoalCard extends StatelessWidget {
  final GoalModel goal;

  const GoalCard({super.key, required this.goal});

  Color get statusColor {
    switch (goal.status) {
      case GoalStatus.onTrack:
        return Colors.green;

      case GoalStatus.attention:
        return Colors.orange;

      case GoalStatus.delayed:
        return Colors.red;

      case GoalStatus.completed:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: statusColor.withValues(alpha: .08),
                child: Icon(goal.icon, color: statusColor),
              ),

              const SizedBox(width: AppSpacing.md),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(goal.title, style: AppTextStyles.cardTitle),

                    const SizedBox(height: 4),

                    Text(
                      goal.statusText,
                      style: AppTextStyles.caption.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              Column(
                children: [
                  Text(
                    '${(goal.progress * 100).round()}%',
                    style: AppTextStyles.cardTitle,
                  ),

                  Text('Progress', style: AppTextStyles.caption),
                ],
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: goal.progress,
              backgroundColor: AppColors.primary.withValues(alpha: .10),
              valueColor: AlwaysStoppedAnimation(statusColor),
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          Row(
            children: [
              Expanded(
                child: _Stat(
                  'Saved',
                  '₹${_formatAmount(goal.currentAmount)} / ₹${_formatAmount(goal.targetAmount)}',
                ),
              ),

              Expanded(
                child: _Stat(
                  'Time Left',
                  goal.monthsLeft == 0
                      ? 'Overdue'
                      : '${goal.monthsLeft} Months',
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          Row(
            children: [
              Expanded(
                child: _Stat(
                  'Monthly Needed',
                  '₹${_formatAmount(goal.requiredMonthlyAmount)}',
                ),
              ),

              Expanded(child: _Stat('Finish', goal.expectedFinish)),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          const Divider(),

          const SizedBox(height: AppSpacing.sm),

          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: statusColor, size: 18),

              const SizedBox(width: 8),

              Expanded(
                child: Text(
                  goal.insight,
                  style: AppTextStyles.caption.copyWith(color: statusColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _formatAmount(double amount) {
    if (amount == amount.roundToDouble()) {
      return amount.toInt().toString();
    }

    return amount.toStringAsFixed(2);
  }
}

class _Stat extends StatelessWidget {
  final String title;
  final String value;

  const _Stat(this.title, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title.toUpperCase(), style: AppTextStyles.caption),

        const SizedBox(height: 6),

        Text(value, style: AppTextStyles.sectionTitle),
      ],
    );
  }
}
