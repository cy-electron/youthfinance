import 'package:flutter/material.dart';

import '../../../../design_system/typography/section_header.dart';
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
          title: "Emergency Fund",
          icon: Icons.savings,
          currentAmount: 25000,
          targetAmount: 50000,
          dueDate: "Dec 2026",
          status: "On Track",
        ),

        const SizedBox(height: 16),

        GoalCard(
          title: "New Laptop",
          icon: Icons.laptop_mac,
          currentAmount: 45000,
          targetAmount: 90000,
          dueDate: "Mar 2027",
          status: "Behind",
        ),
      ],
    );
  }
}
