import 'package:flutter/material.dart';
import 'package:youthfinance/features/goals/data/dummy_goals.dart';

import 'goal_card.dart';

class GoalList extends StatelessWidget {
  const GoalList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: dummyGoals.length,
      separatorBuilder: (_, __) => const SizedBox(height: 20),
      itemBuilder: (_, index) => GoalCard(goal: dummyGoals[index]),
    );
  }
}
