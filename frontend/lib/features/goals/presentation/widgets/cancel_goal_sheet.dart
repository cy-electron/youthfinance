import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:youthfinance/features/goals/model/goal_model.dart';
import 'package:youthfinance/features/goals/model/goal_provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

class CancelGoalSheet extends ConsumerStatefulWidget {
  const CancelGoalSheet({super.key});

  @override
  ConsumerState<CancelGoalSheet> createState() => _CancelGoalSheetState();
}

class _CancelGoalSheetState extends ConsumerState<CancelGoalSheet> {
  int? _cancellingGoalId;

  @override
  Widget build(BuildContext context) {
    final goalsAsync = ref.watch(goalProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: goalsAsync.when(
          // ------------------------------------------------------
          // LOADING
          // ------------------------------------------------------
          loading: () => const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          ),

          // ------------------------------------------------------
          // ERROR
          // ------------------------------------------------------
          error: (error, stackTrace) => SizedBox(
            height: 200,
            child: Center(
              child: Text('Unable to load goals.', style: AppTextStyles.body),
            ),
          ),

          // ------------------------------------------------------
          // DATA
          // ------------------------------------------------------
          data: (goals) {
            final activeGoals = goals
                .where((goal) => !goal.isCompleted)
                .toList();

            if (activeGoals.isEmpty) {
              return const SizedBox(
                height: 180,
                child: Center(
                  child: Text('There are no active goals to cancel.'),
                ),
              );
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ------------------------------------------------
                // HANDLE
                // ------------------------------------------------
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // ------------------------------------------------
                // TITLE
                // ------------------------------------------------
                Text(
                  'Cancel Goal',
                  style: AppTextStyles.heading.copyWith(fontSize: 22),
                ),

                const SizedBox(height: 8),

                Text(
                  'Choose the goal you want to cancel.',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 24),

                // ------------------------------------------------
                // GOALS
                // ------------------------------------------------
                ...activeGoals.map(
                  (goal) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: _CancelGoalTile(
                      goal: goal,
                      isCancelling: _cancellingGoalId == goal.id,
                      disabled: _cancellingGoalId != null,
                      onTap: () => _cancelGoal(goal),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // CANCEL GOAL
  // ============================================================

  Future<void> _cancelGoal(GoalModel goal) async {
    if (_cancellingGoalId != null) {
      return;
    }

    final confirmed = await _showCancelConfirmation(context, goal);

    if (!mounted || !confirmed) {
      return;
    }

    setState(() {
      _cancellingGoalId = goal.id;
    });

    try {
      await ref.read(goalProvider.notifier).deleteGoal(goal.id);

      if (!mounted) {
        return;
      }

      // Return success to GoalsScreen.
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _cancellingGoalId = null;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_errorMessage(error))));
    }
  }

  // ============================================================
  // CONFIRMATION
  // ============================================================

  Future<bool> _showCancelConfirmation(
    BuildContext context,
    GoalModel goal,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Cancel Goal?'),
          content: Text(
            goal.currentAmount > 0
                ? '₹${_format(goal.currentAmount)} saved for '
                      '${goal.title} will be returned to your '
                      'available balance.'
                : 'Are you sure you want to cancel '
                      '${goal.title}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Keep Goal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text(
                'Cancel Goal',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  // ============================================================
  // HELPERS
  // ============================================================

  String _format(double amount) {
    if (amount == amount.roundToDouble()) {
      return amount.toInt().toString();
    }

    return amount.toStringAsFixed(2);
  }

  String _errorMessage(Object error) {
    return 'Unable to cancel goal. Please try again.';
  }
}

// ================================================================
// CANCEL GOAL TILE
// ================================================================

class _CancelGoalTile extends StatelessWidget {
  final GoalModel goal;
  final VoidCallback onTap;
  final bool isCancelling;
  final bool disabled;

  const _CancelGoalTile({
    required this.goal,
    required this.onTap,
    required this.isCancelling,
    required this.disabled,
  });

  @override
  Widget build(BuildContext context) {
    final progress = goal.progress.clamp(0.0, 1.0);

    return Opacity(
      opacity: disabled && !isCancelling ? 0.5 : 1.0,
      child: InkWell(
        onTap: disabled ? null : onTap,
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
              // --------------------------------------------------
              // ICON
              // --------------------------------------------------
              CircleAvatar(
                radius: 23,
                backgroundColor: Colors.red.withValues(alpha: 0.08),
                child: isCancelling
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(goal.icon, color: Colors.red),
              ),

              const SizedBox(width: 14),

              // --------------------------------------------------
              // GOAL DETAILS
              // --------------------------------------------------
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(goal.title, style: AppTextStyles.cardTitle),

                    const SizedBox(height: 5),

                    Text(
                      '₹${_format(goal.currentAmount)} / '
                      '₹${_format(goal.targetAmount)}',
                      style: AppTextStyles.caption,
                    ),

                    const SizedBox(height: 8),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        minHeight: 6,
                        value: progress,
                        backgroundColor: Colors.red.withValues(alpha: 0.08),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // --------------------------------------------------
              // ARROW
              // --------------------------------------------------
              if (!isCancelling)
                Icon(Icons.chevron_right, color: Colors.grey.shade500),
            ],
          ),
        ),
      ),
    );
  }

  String _format(double amount) {
    if (amount == amount.roundToDouble()) {
      return amount.toInt().toString();
    }

    return amount.toStringAsFixed(2);
  }
}
