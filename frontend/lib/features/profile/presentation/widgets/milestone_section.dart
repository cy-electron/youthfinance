import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'milestone_chip.dart';

class MilestoneSection extends StatelessWidget {
  const MilestoneSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Usefull tools", style: AppTextStyles.sectionTitle),

        const SizedBox(height: AppSpacing.sm),

        const SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              MilestoneChip(icon: Icons.import_export, title: "Import data"),

              SizedBox(width: 8),

              MilestoneChip(
                icon: Icons.calendar_month_outlined,
                title: "30 Days\nTracked",
              ),

              SizedBox(width: 8),

              MilestoneChip(
                icon: Icons.savings_outlined,
                title: "Emergency\nFund",
              ),

              SizedBox(width: 8),

              MilestoneChip(
                icon: Icons.trending_up_outlined,
                title: "First\nInvestment",
              ),
            ],
          ),
        ),
      ],
    );
  }
}
