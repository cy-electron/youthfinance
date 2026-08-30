import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../design_system/layout/app_scaffold.dart';

import '../widgets/add_goal_saving_sheet.dart';
import '../widgets/cancel_goal_sheet.dart';
import '../widgets/completed_goals.dart';
import '../widgets/create_goal_sheet.dart';
import '../widgets/goal_action_sheet.dart';
import '../widgets/goal_filter_chips.dart';
import '../widgets/goal_list.dart';
import '../widgets/goal_summary_card.dart';
import '../widgets/select_goal_sheet.dart';
import '../widgets/smart_optimization_card.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  GoalFilter _selectedFilter = GoalFilter.all;

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: _showGoalActions,
        child: const Icon(Icons.add, color: Colors.white),
      ),

      // ----------------------------------------------------------
      // GOALS CONTENT
      // ----------------------------------------------------------
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _GoalsHeader(),

            const SizedBox(height: AppSpacing.xl),

            const GoalSummaryCard(),

            const SizedBox(height: AppSpacing.xl),

            GoalFilterChips(
              selectedFilter: _selectedFilter,
              onFilterChanged: (filter) {
                setState(() {
                  _selectedFilter = filter;
                });
              },
            ),

            const SizedBox(height: AppSpacing.xl),

            GoalList(filter: _selectedFilter),

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

  // ============================================================
  // GOAL ACTIONS
  // ============================================================

  Future<void> _showGoalActions() async {
    final action = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const GoalActionSheet(),
    );

    if (!mounted) return;

    // ----------------------------------------------------------
    // CREATE GOAL
    // ----------------------------------------------------------

    if (action == 'create') {
      await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (_) => const CreateGoalSheet(),
      );

      return;
    }

    // ----------------------------------------------------------
    // ADD MONEY TO GOAL
    // ----------------------------------------------------------

    if (action == 'save') {
      final selectedGoal = await showModalBottomSheet<dynamic>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (_) => const SelectGoalSheet(),
      );

      if (!mounted || selectedGoal == null) {
        return;
      }

      await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (_) {
          return AddGoalSavingSheet(
            goalId: selectedGoal.id,
            goalTitle: selectedGoal.title,
          );
        },
      );

      return;
    }

    // ----------------------------------------------------------
    // CANCEL GOAL
    // ----------------------------------------------------------

    if (action == 'cancel') {
      await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (_) => const CancelGoalSheet(),
      );

      return;
    }
  }
}

// ============================================================
// GOALS HEADER
// ============================================================

class _GoalsHeader extends StatelessWidget {
  const _GoalsHeader();

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
                'Goals',
                style: AppTextStyles.heading.copyWith(fontSize: 28),
              ),

              const SizedBox(height: AppSpacing.xs),

              Text(
                'Build your future, one step at a time.',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: AppSpacing.sm),

        _CircleIconButton(
          icon: Icons.info_outline,
          backgroundColor: Colors.white,
          iconColor: AppColors.textSecondary,
          borderColor: Colors.grey.shade300,
          onTap: () {
            // Information sheet will be implemented next.
          },
        ),
      ],
    );
  }
}

// ============================================================
// CIRCLE ICON BUTTON
// ============================================================

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
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: const SizedBox(
          width: 45,
          height: 45,
          child: Icon(
            Icons.info_outline,
            color: AppColors.textSecondary,
            size: 20,
          ),
        ),
      ),
    );
  }
}
