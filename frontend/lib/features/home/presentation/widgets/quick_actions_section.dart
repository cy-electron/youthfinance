import 'package:flutter/material.dart';

import 'package:youthfinance/design_system/typography/section_header.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../design_system/buttons/action_tile.dart';

import '../../domain/models/quick_action_model.dart';

// Reuse the existing transaction sheets
import '../../../transactions/presentation/widgets/add_income_sheet.dart';
import '../../../transactions/presentation/widgets/add_expense_sheet.dart';

class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({super.key});

  void _showAddIncome(BuildContext context) {
    showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (_) {
        return const AddIncomeSheet();
      },
    );
  }

  void _showAddExpense(BuildContext context) {
    showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (_) {
        return const AddExpenseSheet();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final actions = [
      QuickActionModel(
        title: "Add Income",
        icon: Icons.arrow_downward_rounded,
        color: AppColors.success,
        onTap: () => _showAddIncome(context),
      ),

      QuickActionModel(
        title: "Add Expense",
        icon: Icons.remove_rounded,
        color: AppColors.expense,
        onTap: () => _showAddExpense(context),
      ),

      QuickActionModel(
        title: "Add Goal",
        icon: Icons.flag_rounded,
        color: AppColors.info,
        onTap: () {
          // Coming next
        },
      ),

      QuickActionModel(
        title: "Planner",
        icon: Icons.calendar_month_rounded,
        color: AppColors.primary,
        onTap: () {
          // Coming next
        },
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: "Quick Actions"),

        const SizedBox(height: AppSpacing.md),

        LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth > 700 ? 6 : 4;

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: actions.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: AppSpacing.sm,
                mainAxisSpacing: AppSpacing.sm,
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
