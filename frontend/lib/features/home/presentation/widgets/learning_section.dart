import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
          title: "Financial Learning",
          description:
              "Learn practical money skills through simple, curated videos.",
          duration: "Explore lessons",
          onTap: () {
            context.push('/learning');
          },
        ),
      ],
    );
  }
}