import 'package:flutter/material.dart';

import '../../../../design_system/typography/section_header.dart';
import 'insight_card.dart';

class SmartInsightSection extends StatelessWidget {
  const SmartInsightSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: "Smart Insight"),

        const SizedBox(height: 16),

        InsightCard(
          title: "Great Progress!",
          message:
              "You've spent 18% less on food this month compared to last month. Keep up the consistency!",
          onTap: () {
            // TODO: Navigate to Insights screen
          },
        ),
      ],
    );
  }
}
