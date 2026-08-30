import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youthfinance/features/transactions/expense/expense_provider.dart';
import '../../../../design_system/typography/section_header.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../design_system/cards/app_card.dart';

import '../../../budget/budget_provider.dart';
import '../../../budget/presentation/manage_budget_sheet.dart';

class BudgetSection extends ConsumerWidget {
  const BudgetSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetState = ref.watch(budgetProvider);
    final expenseState = ref.watch(expenseProvider);

    final now = DateTime.now();

    final budgets = budgetState.valueOrNull ?? [];

    final currentBudgets = budgets
        .where((budget) => budget.month == now.month && budget.year == now.year)
        .toList();

    final budget = currentBudgets.isNotEmpty ? currentBudgets.first : null;

    final expenses = expenseState.valueOrNull ?? [];

    final currentExpenses = expenses.where((expense) {
      final date = expense.date;

      return date.month == now.month && date.year == now.year;
    }).toList();

    final spent = currentExpenses.fold<double>(
      0,
      (total, expense) => total + expense.amount,
    );

    if (budget == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: "Monthly Budget"),

          const SizedBox(height: AppSpacing.md),

          const AppCard(child: _NoBudgetContent()),
        ],
      );
    }

    final remaining = budget.amount - spent;

    final progress = budget.amount <= 0
        ? 0.0
        : (spent / budget.amount).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: "Monthly Budget"),

        const SizedBox(height: AppSpacing.md),

        AppCard(
          child: _BudgetInsightContent(
            budgetAmount: budget.amount,
            spent: spent,
            remaining: remaining,
            progress: progress,
            onManagePressed: () {
              _showManageBudget(context);
            },
          ),
        ),
      ],
    );
  }

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
}

// ============================================================
// NO BUDGET
// ============================================================

class _NoBudgetContent extends StatelessWidget {
  const _NoBudgetContent();

  @override
  Widget build(BuildContext context) {
    final monthName = _currentMonthName();

    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(13),
          ),
          child: const Icon(
            Icons.account_balance_wallet_outlined,
            color: AppColors.primary,
            size: 22,
          ),
        ),

        const SizedBox(width: AppSpacing.md),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$monthName Budget',
                style: AppTextStyles.heading.copyWith(fontSize: 17),
              ),

              const SizedBox(height: 3),

              Text(
                'Set a spending limit for this month.',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 10),

              SizedBox(
                height: 34,
                child: FilledButton(
                  onPressed: () {
                    // Existing Create Budget flow
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                  ),
                  child: const Text(
                    'Create Budget',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _currentMonthName() {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return months[DateTime.now().month - 1];
  }
}

// ============================================================
// BUDGET INSIGHT
// ============================================================

class _BudgetInsightContent extends StatelessWidget {
  final double budgetAmount;
  final double spent;
  final double remaining;
  final double progress;
  final VoidCallback onManagePressed;

  const _BudgetInsightContent({
    required this.budgetAmount,
    required this.spent,
    required this.remaining,
    required this.progress,
    required this.onManagePressed,
  });

  @override
  Widget build(BuildContext context) {
    final isOverBudget = spent > budgetAmount;

    final percentage = (progress * 100).round();

    final insight = isOverBudget
        ? 'You are over your monthly budget.'
        : progress >= 0.8
        ? 'You are getting close to your budget limit.'
        : 'You are comfortably within your budget.';

    final insightIcon = isOverBudget
        ? Icons.warning_amber_rounded
        : progress >= 0.8
        ? Icons.info_outline_rounded
        : Icons.check_circle_outline_rounded;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ------------------------------------------------------
        // HEADER
        // ------------------------------------------------------
        Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.account_balance_wallet_outlined,
                color: AppColors.primary,
                size: 21,
              ),
            ),

            const SizedBox(width: AppSpacing.md),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_currentMonthName()} Budget',
                    style: AppTextStyles.heading.copyWith(fontSize: 17),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    'Monthly spending',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            Text(
              '$percentage%',
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.lg),

        // ------------------------------------------------------
        // BUDGET / SPENT
        // ------------------------------------------------------
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: _AmountColumn(label: 'Spent', amount: spent),
            ),

            Expanded(
              child: _AmountColumn(
                label: isOverBudget ? 'Over budget' : 'Remaining',
                amount: remaining.abs(),
                alignEnd: true,
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.md),

        // ------------------------------------------------------
        // PROGRESS
        // ------------------------------------------------------
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: AppColors.primary.withValues(alpha: 0.10),
            valueColor: AlwaysStoppedAnimation<Color>(
              isOverBudget ? Colors.red : AppColors.primary,
            ),
          ),
        ),

        const SizedBox(height: 10),

        // ------------------------------------------------------
        // INSIGHT
        // ------------------------------------------------------
        Row(
          children: [
            Icon(
              insightIcon,
              size: 17,
              color: isOverBudget ? Colors.red : AppColors.primary,
            ),

            const SizedBox(width: 6),

            Expanded(
              child: Text(
                insight,
                style: AppTextStyles.body.copyWith(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.md),

        // ------------------------------------------------------
        // MANAGE
        // ------------------------------------------------------
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: onManagePressed,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Manage Budget →',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  String _currentMonthName() {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return months[DateTime.now().month - 1];
  }
}

// ============================================================
// AMOUNT
// ============================================================

class _AmountColumn extends StatelessWidget {
  final String label;
  final double amount;
  final bool alignEnd;

  const _AmountColumn({
    required this.label,
    required this.amount,
    this.alignEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.body.copyWith(
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
        ),

        const SizedBox(height: 2),

        Text(
          '₹${amount.toStringAsFixed(0)}',
          style: AppTextStyles.heading.copyWith(fontSize: 20),
        ),
      ],
    );
  }
}
