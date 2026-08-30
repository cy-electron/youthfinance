import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../design_system/typography/section_header.dart';
import '../../../goals/model/goal_provider.dart';
import '../../../goals/presentation/widgets/goal_card.dart';

class ActiveGoalsSection extends ConsumerWidget {
  const ActiveGoalsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(goalProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Active Goals',
          actionText: 'See All',
          onPressed: () {
            // TODO: Connect to Goals tab navigation.
          },
        ),

        const SizedBox(height: 16),

        goalsAsync.when(
          // --------------------------------------------------
          // LOADING
          // --------------------------------------------------
          loading: () {
            return const SizedBox(
              height: 160,
              child: Center(child: CircularProgressIndicator()),
            );
          },

          // --------------------------------------------------
          // ERROR
          // --------------------------------------------------
          error: (error, stackTrace) {
            return _buildEmptyState(
              icon: Icons.error_outline_rounded,
              message: 'Unable to load your goals.',
            );
          },

          // --------------------------------------------------
          // DATA
          // --------------------------------------------------
          data: (goals) {
            final activeGoals = goals
                .where((goal) => !goal.isCompleted)
                .take(2)
                .toList();

            // ------------------------------------------------
            // NO ACTIVE GOALS
            // ------------------------------------------------

            if (activeGoals.isEmpty) {
              return _buildEmptyState(
                icon: Icons.flag_outlined,
                message: 'No active goals yet.',
              );
            }

            // ------------------------------------------------
            // ACTIVE GOALS
            // ------------------------------------------------

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

  // ------------------------------------------------------------
  // EMPTY / ERROR STATE
  // ------------------------------------------------------------

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
