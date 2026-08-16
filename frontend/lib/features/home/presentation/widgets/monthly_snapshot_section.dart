import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

import '../../../../design_system/cards/summary_card.dart';
import '../../../../design_system/typography/section_header.dart';

import '../../../transactions/income/income_provider.dart';
import '../../../transactions/expense/expense_provider.dart';

class MonthlySnapshotSection extends ConsumerWidget {
  const MonthlySnapshotSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incomeState = ref.watch(incomeProvider);
    final expenseState = ref.watch(expenseProvider);

    final incomes = incomeState.valueOrNull ?? [];
    final expenses = expenseState.valueOrNull ?? [];

    final now = DateTime.now();

    // ------------------------------------------------------------
    // CURRENT MONTH
    // ------------------------------------------------------------

    final currentIncome = incomes
        .where(
          (income) =>
              income.date.year == now.year && income.date.month == now.month,
        )
        .fold<double>(0, (sum, income) => sum + income.amount);

    final currentExpense = expenses
        .where(
          (expense) =>
              expense.date.year == now.year && expense.date.month == now.month,
        )
        .fold<double>(0, (sum, expense) => sum + expense.amount);

    final currentSavings = currentIncome - currentExpense;

    // ------------------------------------------------------------
    // PREVIOUS MONTH
    // ------------------------------------------------------------

    final previousMonth = DateTime(now.year, now.month - 1);

    final previousIncome = incomes
        .where(
          (income) =>
              income.date.year == previousMonth.year &&
              income.date.month == previousMonth.month,
        )
        .fold<double>(0, (sum, income) => sum + income.amount);

    final previousExpense = expenses
        .where(
          (expense) =>
              expense.date.year == previousMonth.year &&
              expense.date.month == previousMonth.month,
        )
        .fold<double>(0, (sum, expense) => sum + expense.amount);

    final previousSavings = previousIncome - previousExpense;

    // ------------------------------------------------------------
    // MONTH-OVER-MONTH CHANGE
    // ------------------------------------------------------------

    final incomeChange = _calculatePercentageChange(
      previousIncome,
      currentIncome,
    );

    final expenseChange = _calculatePercentageChange(
      previousExpense,
      currentExpense,
    );

    final savingsChange = _calculatePercentageChange(
      previousSavings,
      currentSavings,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: "Monthly Snapshot"),

        const SizedBox(height: AppSpacing.md),

        // ---- SAME EXISTING UI ----
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 160,
                  child: SummaryCard(
                    icon: Icons.account_balance_wallet_outlined,
                    iconColor: AppColors.primary,
                    title: "Income",
                    value: _formatAmount(currentIncome),
                    change: _formatChange(incomeChange),
                    changeColor: incomeChange >= 0
                        ? AppColors.success
                        : AppColors.expense,
                  ),
                ),

                const SizedBox(width: AppSpacing.md),

                SizedBox(
                  width: 160,
                  child: SummaryCard(
                    icon: Icons.credit_card,
                    iconColor: AppColors.expense,
                    title: "Expenses",
                    value: _formatAmount(currentExpense),
                    change: _formatChange(expenseChange),
                    changeColor: expenseChange <= 0
                        ? AppColors.success
                        : AppColors.expense,
                  ),
                ),

                const SizedBox(width: AppSpacing.md),

                SizedBox(
                  width: 160,
                  child: SummaryCard(
                    icon: Icons.savings_outlined,
                    iconColor: AppColors.success,
                    title: "Savings",
                    value: _formatAmount(currentSavings),
                    change: _formatChange(savingsChange),
                    changeColor: savingsChange >= 0
                        ? AppColors.success
                        : AppColors.expense,
                  ),
                ),

                const SizedBox(width: AppSpacing.md),

                // Budget remains untouched for now.
                const SizedBox(
                  width: 160,
                  child: SummaryCard(
                    icon: Icons.account_balance_wallet,
                    iconColor: AppColors.primary,
                    title: "Budget Left",
                    value: "₹8,000",
                    showProgress: true,
                    progress: .65,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // HELPERS
  // ------------------------------------------------------------

  double _calculatePercentageChange(double previous, double current) {
    if (previous == 0) {
      if (current == 0) {
        return 0;
      }

      // No previous-month value to compare against.
      return 0;
    }

    return ((current - previous) / previous) * 100;
  }

  String _formatAmount(double amount) {
    return "₹${amount.toStringAsFixed(0)}";
  }

  String _formatChange(double change) {
    if (change == 0) {
      return "0%";
    }

    final sign = change > 0 ? "+" : "";

    return "$sign${change.toStringAsFixed(0)}%";
  }
}
