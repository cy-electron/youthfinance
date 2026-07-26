import 'package:flutter/material.dart';

import '../../../../design_system/typography/section_header.dart';
import 'learning_card.dart';

class LearningSection extends StatelessWidget {
  const LearningSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: "Learn & Grow"),

        const SizedBox(height: 12),

        LearningCard(
          title: "Understanding Emergency Funds",
          description:
              "Learn why building an emergency fund is one of the most important financial habits.",
          duration: "5 min read",
          onTap: () {},
        ),
      ],
    );
  }
}
