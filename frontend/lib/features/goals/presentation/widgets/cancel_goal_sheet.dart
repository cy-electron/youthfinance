import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:youthfinance/features/goals/model/goal_model.dart';
import 'package:youthfinance/features/goals/model/goal_provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

class CancelGoalSheet extends ConsumerWidget {
  const CancelGoalSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(goalProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: goalsAsync.when(
          loading: () => const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          ),

          error: (error, stackTrace) => SizedBox(
            height: 200,
            child: Center(
              child: Text('Unable to load goals.', style: AppTextStyles.body),
            ),
          ),

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

                ...activeGoals.map(
                  (goal) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: _CancelGoalTile(
                      goal: goal,
                      onTap: () async {
                        final confirmed = await _showCancelConfirmation(
                          context,
                          goal,
                        );

                        if (!context.mounted || !confirmed) {
                          return;
                        }

                        try {
                          await ref
                              .read(goalProvider.notifier)
                              .deleteGoal(goal.id);

                          if (!context.mounted) return;

                          Navigator.pop(context, true);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Goal cancelled successfully.'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        } catch (error) {
                          if (!context.mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Unable to cancel goal.'),
                            ),
                          );
                        }
                      },
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
                      '${goal.title} will become unassigned savings.'
                : 'Are you sure you want to cancel ${goal.title}?',
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

  String _format(double amount) {
    if (amount == amount.roundToDouble()) {
      return amount.toInt().toString();
    }

    return amount.toStringAsFixed(2);
  }
}

class _CancelGoalTile extends StatelessWidget {
  final GoalModel goal;
  final VoidCallback onTap;

  const _CancelGoalTile({required this.goal, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final progress = goal.progress.clamp(0.0, 1.0);

    return InkWell(
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
              backgroundColor: Colors.red.withValues(alpha: 0.08),
              child: Icon(goal.icon, color: Colors.red),
            ),

            const SizedBox(width: 14),

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

            Icon(Icons.chevron_right, color: Colors.grey.shade500),
          ],
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
