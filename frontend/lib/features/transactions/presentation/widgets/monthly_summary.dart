import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../design_system/cards/app_card.dart';
import '../../income/income_model.dart';
import '../../income/income_provider.dart';
import '../../expense/expense_model.dart';
import '../../expense/expense_provider.dart';

class MonthlySummary extends ConsumerWidget {
  const MonthlySummary({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incomeState = ref.watch(incomeProvider);
    final expenseState = ref.watch(expenseProvider);

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: incomeState.when(
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.all(8),
            child: CircularProgressIndicator(),
          ),
        ),

        error: (error, _) => Text(
          'Unable to load income',
          style: AppTextStyles.body.copyWith(color: Colors.red),
        ),

        data: (List<IncomeModel> incomes) {
          return expenseState.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(8),
                child: CircularProgressIndicator(),
              ),
            ),

            error: (error, _) => Text(
              'Unable to load expenses',
              style: AppTextStyles.body.copyWith(color: Colors.red),
            ),

            data: (List<ExpenseModel> expenses) {
              final now = DateTime.now();

              // Current month
              final currentMonthIncomes = incomes.where((income) {
                return income.date.year == now.year &&
                    income.date.month == now.month;
              }).toList();

              final currentMonthExpenses = expenses.where((expense) {
                return expense.date.year == now.year &&
                    expense.date.month == now.month;
              }).toList();

              final totalIncome = currentMonthIncomes.fold<double>(
                0,
                (sum, income) => sum + income.amount,
              );

              final totalExpense = currentMonthExpenses.fold<double>(
                0,
                (sum, expense) => sum + expense.amount,
              );

              final netSavings = totalIncome - totalExpense;

              return Row(
                children: [
                  Expanded(
                    child: _SummaryItem(
                      title: "Income",
                      value: _formatAmount(totalIncome),
                    ),
                  ),

                  Expanded(
                    child: _SummaryItem(
                      title: "Expense",
                      value: _formatAmount(totalExpense),
                    ),
                  ),

                  Expanded(
                    child: _SummaryItem(
                      title: "Net Savings",
                      value:
                          "${netSavings >= 0 ? '+' : '-'}₹${netSavings.abs().toStringAsFixed(0)}",
                      isPositive: netSavings >= 0,
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  String _formatAmount(double amount) {
    return "₹${amount.toStringAsFixed(0)}";
  }
}

class _SummaryItem extends StatelessWidget {
  final String title;
  final String value;
  final bool isPositive;

  const _SummaryItem({
    required this.title,
    required this.value,
    this.isPositive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title.toUpperCase(),
          style: AppTextStyles.caption.copyWith(letterSpacing: 1),
        ),

        const SizedBox(height: AppSpacing.sm),

        Text(
          value,
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w700,
            color: isPositive ? AppColors.success : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
