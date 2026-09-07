import 'package:flutter/material.dart';

import 'package:youthfinance/design_system/typography/section_header.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../design_system/buttons/action_tile.dart';

import '../../domain/models/quick_action_model.dart';

// Transactions
import '../../../transactions/presentation/widgets/add_income_sheet.dart';
import '../../../transactions/presentation/widgets/add_expense_sheet.dart';

// Goals
import '../../../goals/presentation/widgets/create_goal_sheet.dart';

// Budget
import '../../../budget/presentation/manage_budget_sheet.dart';

class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({super.key});

  // ------------------------------------------------------------
  // ADD INCOME
  // ------------------------------------------------------------

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

  // ------------------------------------------------------------
  // ADD EXPENSE
  // ------------------------------------------------------------

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

  // ------------------------------------------------------------
  // ADD GOAL
  // ------------------------------------------------------------

  Future<void> _showAddGoal(BuildContext context) async {
    await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (_) {
        return const CreateGoalSheet();
      },
    );
  }

  // ------------------------------------------------------------
  // MANAGE BUDGET
  // ------------------------------------------------------------

  void _showManageBudget(BuildContext context) {
    showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (_) {
        return const ManageBudgetSheet();
      },
    );
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------

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
        onTap: () => _showAddGoal(context),
      ),

      QuickActionModel(
        title: "Manage Budget",
        icon: Icons.account_balance_wallet_rounded,
        color: AppColors.primary,
        onTap: () => _showManageBudget(context),
      ),

      //QuickActionModel(
        //title: "Planner",
        //icon: Icons.calendar_month_rounded,
       // color: AppColors.primary,
        //onTap: () {
        //  // Coming next
       // },
      //),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: "Quick Actions"),

        const SizedBox(height: AppSpacing.md),

        LayoutBuilder(
          builder: (context, constraints) {
            const visibleItems = 4;

            final tileWidth =
                (constraints.maxWidth - (AppSpacing.sm * (visibleItems - 1))) /
                visibleItems;

            return SizedBox(
              height: tileWidth / 0.75,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: actions.length,
                separatorBuilder: (_, __) {
                  return const SizedBox(width: AppSpacing.sm);
                },
                itemBuilder: (context, index) {
                  final item = actions[index];

                  return SizedBox(
                    width: tileWidth,
                    child: ActionTile(
                      icon: item.icon,
                      title: item.title,
                      color: item.color,
                      onTap: item.onTap,
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
