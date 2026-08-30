import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youthfinance/features/goals/model/goal_provider.dart';

import 'goal_card.dart';
import 'goal_filter_chips.dart';

class GoalList extends ConsumerWidget {
  final GoalFilter filter;

  const GoalList({super.key, required this.filter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(goalProvider);

    return goalsAsync.when(
      // ----------------------------------------------------------
      // LOADING
      // ----------------------------------------------------------
      loading: () {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: CircularProgressIndicator(),
          ),
        );
      },

      // ----------------------------------------------------------
      // ERROR
      // ----------------------------------------------------------
      error: (error, stackTrace) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Icon(Icons.error_outline, size: 40),

                const SizedBox(height: 12),

                const Text(
                  'Unable to load your goals.',
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                TextButton(
                  onPressed: () {
                    ref.read(goalProvider.notifier).refresh();
                  },
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
        );
      },

      // ----------------------------------------------------------
      // DATA
      // ----------------------------------------------------------
      data: (goals) {
        final filteredGoals = goals.where((goal) {
          switch (filter) {
            case GoalFilter.all:
              return true;

            case GoalFilter.active:
              return !goal.isCompleted;

            case GoalFilter.completed:
              return goal.isCompleted;
          }
        }).toList();

        // --------------------------------------------------------
        // EMPTY STATE
        // --------------------------------------------------------

        if (filteredGoals.isEmpty) {
          return _EmptyGoalsState(filter: filter);
        }

        // --------------------------------------------------------
        // GOAL LIST
        // --------------------------------------------------------

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filteredGoals.length,
          separatorBuilder: (_, __) {
            return const SizedBox(height: 20);
          },
          itemBuilder: (_, index) {
            return GoalCard(goal: filteredGoals[index]);
          },
        );
      },
    );
  }
}

// ============================================================
// EMPTY STATE
// ============================================================

class _EmptyGoalsState extends StatelessWidget {
  final GoalFilter filter;

  const _EmptyGoalsState({required this.filter});

  @override
  Widget build(BuildContext context) {
    String title;
    String description;
    IconData icon;

    switch (filter) {
      case GoalFilter.all:
        title = 'No goals yet.';
        description = 'Create your first goal and start building your future.';
        icon = Icons.flag_outlined;
        break;

      case GoalFilter.active:
        title = 'No active goals.';
        description = 'Create a goal and start working towards it.';
        icon = Icons.flag_outlined;
        break;

      case GoalFilter.completed:
        title = 'No completed goals yet.';
        description = 'Completed goals will appear here.';
        icon = Icons.check_circle_outline;
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      child: Column(
        children: [
          Icon(icon, size: 48, color: Colors.grey.shade400),

          const SizedBox(height: 12),

          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 6),

          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
