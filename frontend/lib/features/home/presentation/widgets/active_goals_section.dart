import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../design_system/typography/section_header.dart';
import '../../../goals/model/goal_provider.dart';
import '../../../goals/presentation/widgets/goal_card.dart';

class ActiveGoalsSection extends ConsumerWidget {
  final VoidCallback? onNavigateToGoals;

  const ActiveGoalsSection({super.key, this.onNavigateToGoals});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(goalProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Active Goals',
          actionText: 'See All',
          onPressed: onNavigateToGoals,
        ),

        const SizedBox(height: 16),

        goalsAsync.when(
          loading: () {
            return const SizedBox(
              height: 160,
              child: Center(child: CircularProgressIndicator()),
            );
          },

          error: (error, stackTrace) {
            return _buildEmptyState(
              icon: Icons.error_outline_rounded,
              message: 'Unable to load your goals.',
            );
          },

          data: (goals) {
            final activeGoals = goals
                .where((goal) => !goal.isCompleted)
                .take(2)
                .toList();

            if (activeGoals.isEmpty) {
              return _buildEmptyState(
                icon: Icons.flag_outlined,
                message: 'No active goals yet.',
              );
            }

            return Column(
              children: [
                for (int index = 0; index < activeGoals.length; index++) ...[
                  GoalCard(goal: activeGoals[index]),

                  if (index < activeGoals.length - 1)
                    const SizedBox(height: 16),
                ],
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildEmptyState({required IconData icon, required String message}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: Colors.grey.shade500),
          const SizedBox(height: 10),
          Text(message, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
