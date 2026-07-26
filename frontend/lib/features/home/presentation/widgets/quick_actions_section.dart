import 'package:flutter/material.dart';
import 'package:youthfinance/design_system/typography/section_header.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../design_system/buttons/action_tile.dart';
//import '../../../../design_system/layout/section_header.dart';
import '../../domain/models/quick_action_model.dart';

class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = [
      QuickActionModel(
        title: "Add Income",
        icon: Icons.arrow_downward_rounded,
        color: AppColors.success,
        onTap: () {},
      ),

      QuickActionModel(
        title: "Add Expense",
        icon: Icons.remove_rounded,
        color: AppColors.expense,
        onTap: () {},
      ),

      QuickActionModel(
        title: "Add Goal",
        icon: Icons.flag_rounded,
        color: AppColors.info,
        onTap: () {},
      ),

      QuickActionModel(
        title: "Planner",
        icon: Icons.calendar_month_rounded,
        color: AppColors.primary,
        onTap: () {},
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: "Quick Actions"),

        const SizedBox(height: AppSpacing.md),

        LayoutBuilder(
          builder: (context, constraints) {
            // On a phone this stays at 4 columns, which lays all 4 tiles
            // out in a single row (matches the design). The 6-column branch
            // only kicks in on wide/tablet layouts.
            final crossAxisCount = constraints.maxWidth > 700 ? 6 : 4;

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: actions.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                // Narrower gaps between tiles (was AppSpacing.md).
                crossAxisSpacing: AppSpacing.sm,
                mainAxisSpacing: AppSpacing.sm,
                // Slightly taller than wide (icon circle + up to a
                // 2-line label). Lowered further from .85 to give the
                // larger icon/text in ActionTile more room, so FittedBox
                // doesn't shrink it back down to compensate.
                childAspectRatio: .75,
              ),

              itemBuilder: (context, index) {
                final item = actions[index];

                return ActionTile(
                  icon: item.icon,
                  title: item.title,
                  color: item.color,
                  onTap: item.onTap,
                );
              },
            );
          },
        ),
      ],
    );
  }
}
