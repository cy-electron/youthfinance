import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youthfinance/features/goals/model/goal_provider.dart';

import '../../../../core/theme/app_text_styles.dart';

class CompletedGoals extends ConsumerWidget {
  const CompletedGoals({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(goalProvider);

    return goalsAsync.when(
      loading: () => const SizedBox.shrink(),

      error: (_, __) => const SizedBox.shrink(),

      data: (goals) {
        final completedGoals = goals.where((goal) => goal.isCompleted).toList();

        if (completedGoals.isEmpty) {
          return const SizedBox.shrink();
        }

        return ExpansionTile(
          tilePadding: EdgeInsets.zero,
          title: Text(
            'Completed Goals (${completedGoals.length})',
            style: AppTextStyles.sectionTitle,
          ),
          children: completedGoals.map((goal) {
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.check_circle),
              title: Text(goal.title),
              subtitle: Text('₹${goal.currentAmount.toInt()} saved'),
            );
          }).toList(),
        );
      },
    );
  }
}
