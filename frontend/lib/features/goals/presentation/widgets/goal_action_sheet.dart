import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

class GoalActionSheet extends StatelessWidget {
  const GoalActionSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 42,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            Text(
              'Goal Actions',
              style: AppTextStyles.heading.copyWith(fontSize: 22),
            ),

            const SizedBox(height: AppSpacing.xs),

            Text(
              'What would you like to do?',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // --------------------------------------------------
            // CREATE GOAL
            // --------------------------------------------------
            _GoalActionOption(
              icon: Icons.flag_outlined,
              title: 'Create Goal',
              subtitle: 'Start a new financial goal',
              iconColor: AppColors.primary,
              onTap: () {
                Navigator.pop(context, 'create');
              },
            ),

            const SizedBox(height: AppSpacing.sm),

            // --------------------------------------------------
            // ADD MONEY TO GOAL
            // --------------------------------------------------
            _GoalActionOption(
              icon: Icons.savings_outlined,
              title: 'Add Money to Goal',
              subtitle: 'Allocate savings to a goal',
              iconColor: AppColors.primary,
              onTap: () {
                Navigator.pop(context, 'save');
              },
            ),

            const SizedBox(height: AppSpacing.sm),

            // --------------------------------------------------
            // CANCEL GOAL
            // --------------------------------------------------
            _GoalActionOption(
              icon: Icons.cancel_outlined,
              title: 'Cancel Goal',
              subtitle: 'Remove a goal and return its saved money',
              iconColor: Colors.red,
              onTap: () {
                Navigator.pop(context, 'cancel');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalActionOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final VoidCallback onTap;

  const _GoalActionOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 23,
                backgroundColor: iconColor.withValues(alpha: 0.08),
                child: Icon(icon, color: iconColor, size: 22),
              ),

              const SizedBox(width: AppSpacing.md),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.cardTitle),

                    const SizedBox(height: 4),

                    Text(
                      subtitle,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              Icon(Icons.chevron_right, color: Colors.grey.shade500),
            ],
          ),
        ),
      ),
    );
  }
}
