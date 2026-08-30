import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:youthfinance/features/goals/model/goal_provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../design_system/cards/app_card.dart';

class GoalSummaryCard extends ConsumerWidget {
  const GoalSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(goalProvider);

    return goalsAsync.when(
      loading: () => const AppCard(
        child: SizedBox(
          height: 130,
          child: Center(child: CircularProgressIndicator()),
        ),
      ),

      error: (_, __) => const AppCard(child: Text('Goal summary unavailable.')),

      data: (goals) {
        final activeGoals = goals.where((goal) => !goal.isCompleted).toList();

        final totalTarget = activeGoals.fold<double>(
          0,
          (sum, goal) => sum + goal.targetAmount,
        );

        final totalSaved = activeGoals.fold<double>(
          0,
          (sum, goal) => sum + goal.currentAmount,
        );

        final progress = totalTarget <= 0
            ? 0.0
            : (totalSaved / totalTarget).clamp(0.0, 1.0);

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
                backgroundColor: AppColors.primary.withValues(alpha: .10),
                center: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${(progress * 100).round()}%',
                      style: AppTextStyles.heading.copyWith(
                        fontSize: 28,
                        height: 1,
                      ),
                    ),

                    Text('Overall', style: AppTextStyles.caption),
                  ],
                ),
              ),

              const SizedBox(width: AppSpacing.lg),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _SummaryItem(
                            title: 'ACTIVE',
                            value: activeGoals.length.toString(),
                          ),
                        ),

                        Expanded(
                          child: _SummaryItem(
                            title: 'SAVED',
                            value: '₹${_formatAmount(totalSaved)}',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.md),

                    _SummaryItem(
                      title: 'TOTAL TARGET',
                      value: '₹${_formatAmount(totalTarget)}',
                      valueColor: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static String _formatAmount(double amount) {
    if (amount == amount.roundToDouble()) {
      return amount.toInt().toString();
    }

    return amount.toStringAsFixed(2);
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
