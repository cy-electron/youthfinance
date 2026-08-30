import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:youthfinance/features/analytics/presentation/screens/dashboard_provider.dart';
import 'package:youthfinance/features/transactions/model/transaction_model.dart';
import 'package:youthfinance/features/transactions/model/transaction_provider.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../design_system/cards/app_card.dart';

import 'overview_metric.dart';

class MonthlyOverviewCard extends ConsumerWidget {
  const MonthlyOverviewCard({super.key});

  String formatAmount(double amount) {
    return '₹${amount.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(dashboardProvider);
    final transactions = ref.watch(transactionProvider);

    return AppCard(
      child: dashboard.when(
        loading: () {
          return const SizedBox(
            height: 140,
            child: Center(child: CircularProgressIndicator()),
          );
        },

        error: (error, stack) {
          return const SizedBox(
            height: 140,
            child: Center(child: Text('Unable to load dashboard')),
          );
        },

        data: (dashboardData) {
          return transactions.when(
            loading: () {
              return const SizedBox(
                height: 140,
                child: Center(child: CircularProgressIndicator()),
              );
            },

            error: (error, stack) {
              return const SizedBox(
                height: 140,
                child: Center(child: Text('Unable to load transactions')),
              );
            },

            data: (allTransactions) {
              final now = DateTime.now();

              // Only Income and Expenses from the current month.
              final currentMonthTransactions = allTransactions.where((
                transaction,
              ) {
                return transaction.date.year == now.year &&
                    transaction.date.month == now.month;
              }).toList();

              final currentMonthIncome = currentMonthTransactions
                  .where(
                    (transaction) => transaction.type == TransactionType.income,
                  )
                  .fold(0.0, (sum, transaction) => sum + transaction.amount);

              final currentMonthExpense = currentMonthTransactions
                  .where(
                    (transaction) =>
                        transaction.type == TransactionType.expense,
                  )
                  .fold(0.0, (sum, transaction) => sum + transaction.amount);

              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: OverviewMetric(
                          title: 'Income',
                          value: formatAmount(currentMonthIncome),
                          change: '',
                          positive: true,
                        ),
                      ),

                      const SizedBox(width: AppSpacing.lg),

                      Expanded(
                        child: OverviewMetric(
                          title: 'Expenses',
                          value: formatAmount(currentMonthExpense),
                          change: '',
                          positive: false,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  Row(
                    children: [
                      Expanded(
                        child: OverviewMetric(
                          title: 'Savings',
                          value: formatAmount(dashboardData.netSavings),
                          change: '',
                          positive: dashboardData.netSavings >= 0,
                        ),
                      ),

                      const SizedBox(width: AppSpacing.lg),

                      Expanded(
                        child: OverviewMetric(
                          title: 'Budget',
                          value: formatAmount(dashboardData.monthlyBudget),
                          change: '',
                          positive: true,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
