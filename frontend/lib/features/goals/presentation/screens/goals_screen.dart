import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../design_system/layout/app_scaffold.dart';

import '../widgets/completed_goals.dart';
import '../widgets/goal_filter_chips.dart';
import '../widgets/goal_list.dart';
import '../widgets/goal_summary_card.dart';
import '../widgets/smart_optimization_card.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      // No `title`/`floatingActionButton` here anymore — the design's
      // header (title + subtitle + info button + add button, all in
      // one row) is custom and lives inside `body` below instead of
      // AppScaffold's default AppBar + separate floating action button.
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _GoalsHeader(onAddPressed: () {}, onInfoPressed: () {}),

            const SizedBox(height: AppSpacing.xl),

            const GoalSummaryCard(),

            const SizedBox(height: AppSpacing.xl),

            const GoalFilterChips(),

            const SizedBox(height: AppSpacing.xl),

            const GoalList(),

            const SizedBox(height: AppSpacing.xl),

            const SmartOptimizationCard(),

            const SizedBox(height: AppSpacing.xl),

            const CompletedGoals(),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

class _GoalsHeader extends StatelessWidget {
  final VoidCallback onAddPressed;
  final VoidCallback onInfoPressed;

  const _GoalsHeader({required this.onAddPressed, required this.onInfoPressed});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Goals",
                style: AppTextStyles.heading.copyWith(fontSize: 28),
              ),

              const SizedBox(height: AppSpacing.xs),

              Text(
                "Build your future, one step at a time.",
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: AppSpacing.sm),

        // Outlined info button
        _CircleIconButton(
          icon: Icons.info_outline,
          backgroundColor: Colors.white,
          iconColor: AppColors.textSecondary,
          borderColor: Colors.grey.shade300,
          onTap: onInfoPressed,
        ),

        const SizedBox(width: AppSpacing.sm),

        // Filled green add button (replaces the old bottom-right FAB)
        _CircleIconButton(
          icon: Icons.add,
          backgroundColor: AppColors.primary,
          iconColor: Colors.white,
          onTap: onAddPressed,
        ),
      ],
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final Color? borderColor;
  final VoidCallback onTap;

  const _CircleIconButton({
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    required this.onTap,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      shape: CircleBorder(
        side: borderColor != null
            ? BorderSide(color: borderColor!)
            : BorderSide.none,
      ),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 45,
          height: 45,
          child: Icon(icon, color: iconColor, size: 20),
        ),
      ),
    );
  }
}
