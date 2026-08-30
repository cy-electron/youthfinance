import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:youthfinance/features/transactions/expense/expense_provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../design_system/cards/app_card.dart';

class SpendingBreakdownCard extends ConsumerWidget {
  const SpendingBreakdownCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenseState = ref.watch(expenseProvider);

    return AppCard(
      child: expenseState.when(
        loading: () {
          return const SizedBox(
            height: 300,
            child: Center(child: CircularProgressIndicator()),
          );
        },
        error: (error, stack) {
          return const SizedBox(
            height: 300,
            child: Center(child: Text('Unable to load spending data')),
          );
        },
        data: (expenses) {
          final now = DateTime.now();

          // Only expenses from the current month.
          final currentMonthExpenses = expenses.where((expense) {
            return expense.date.year == now.year &&
                expense.date.month == now.month;
          }).toList();

          // Group expenses by category.
          final Map<String, double> categoryTotals = {};

          for (final expense in currentMonthExpenses) {
            categoryTotals[expense.category] =
                (categoryTotals[expense.category] ?? 0) + expense.amount;
          }

          final totalSpend = categoryTotals.values.fold(
            0.0,
            (sum, amount) => sum + amount,
          );

          // No expenses this month.
          if (categoryTotals.isEmpty || totalSpend == 0) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Spending Breakdown',
                      style: AppTextStyles.sectionTitle,
                    ),
                    Text(
                      _monthName(now.month),
                      style: AppTextStyles.caption.copyWith(
                        color: const Color.fromARGB(255, 41, 43, 41),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.lg),

                const SizedBox(
                  height: 230,
                  child: Center(child: Text('No expenses recorded this month')),
                ),
              ],
            );
          }

          // Sort largest categories first.
          final sortedCategories = categoryTotals.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

          // Give each category a chart color.
          final chartColors = [
            AppColors.primary,
            Colors.blue,
            Colors.amber,
            Colors.grey,
            Colors.orange,
            Colors.purple,
            Colors.teal,
            Colors.indigo,
          ];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Spending Breakdown', style: AppTextStyles.sectionTitle),
                  Text(
                    _monthName(now.month),
                    style: AppTextStyles.caption.copyWith(
                      color: const Color.fromARGB(255, 41, 43, 41),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.lg),

              SizedBox(
                height: 230,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        sectionsSpace: 4,
                        centerSpaceRadius: 62,
                        borderData: FlBorderData(show: false),

                        sections: List.generate(sortedCategories.length, (
                          index,
                        ) {
                          final category = sortedCategories[index];

                          return PieChartSectionData(
                            value: category.value,
                            color: chartColors[index % chartColors.length],
                            radius: 20,
                            title: '',
                          );
                        }),
                      ),
                    ),

                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('TOTAL SPEND', style: AppTextStyles.caption),
                        Text(
                          _formatAmount(totalSpend),
                          style: AppTextStyles.heading,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              Wrap(
                spacing: 18,
                runSpacing: 10,
                children: List.generate(sortedCategories.length, (index) {
                  final category = sortedCategories[index];

                  return _Legend(
                    color: chartColors[index % chartColors.length],
                    title: category.key,
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }

  static String _formatAmount(double amount) {
    return '₹${amount.toStringAsFixed(0)}';
  }

  static String _monthName(int month) {
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

    return months[month - 1];
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String title;

  const _Legend({required this.color, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(radius: 5, backgroundColor: color),
        const SizedBox(width: 6),
        Text(title, style: AppTextStyles.caption),
      ],
    );
  }
}
