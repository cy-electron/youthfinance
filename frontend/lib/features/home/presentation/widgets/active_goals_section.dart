import 'package:flutter/material.dart';

import '../../../../design_system/typography/section_header.dart';
import '../../../goals/data/dummy_goals.dart';
import '../../../goals/presentation/widgets/goal_card.dart';

class ActiveGoalsSection extends StatelessWidget {
  const ActiveGoalsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: "Active Goals",
          actionText: "See All",
          onPressed: () {
            // TODO: Navigate to Goals screen
          },
        ),

        const SizedBox(height: 16),

        GoalCard(
          goal: dummyGoals[2], // Emergency Fund
        ),

        const SizedBox(height: 16),

        GoalCard(
          goal: dummyGoals[1], // MacBook Pro
        ),
      ],
    );
  }
}
