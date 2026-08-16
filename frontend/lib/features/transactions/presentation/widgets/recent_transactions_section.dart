import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youthfinance/features/transactions/model/transaction_model.dart';
import 'package:youthfinance/features/transactions/model/transaction_provider.dart';

import '../../../../design_system/cards/app_card.dart';
import '../../../../design_system/typography/section_header.dart';
import '../../../transactions/presentation/widgets/transaction_tile.dart';

class RecentTransactionsSection extends ConsumerWidget {
  const RecentTransactionsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionState = ref.watch(transactionProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: "Recent Transactions",
          actionText: "View All",
          onPressed: () {
            // Navigation to Transactions can be connected later.
          },
        ),

        const SizedBox(height: 16),

        transactionState.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          ),

          error: (error, stackTrace) => AppCard(
            child: Text(
              'Unable to load transactions',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),

          data: (transactions) {
            if (transactions.isEmpty) {
              return const AppCard(child: Text('No transactions yet.'));
            }

            final recentTransactions = transactions.take(3).toList();

            return AppCard(
              child: Column(
                children: [
                  for (int i = 0; i < recentTransactions.length; i++) ...[
                    TransactionTile(
                      icon: _getIcon(recentTransactions[i]),
                      title: recentTransactions[i].title,
                      subtitle: _getSubtitle(recentTransactions[i]),
                      amount: recentTransactions[i].amount,
                      isIncome: recentTransactions[i].isIncome,
                    ),

                    if (i < recentTransactions.length - 1) const Divider(),
                  ],
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  String _getSubtitle(TransactionModel transaction) {
    if (transaction.description != null &&
        transaction.description!.trim().isNotEmpty) {
      return transaction.description!;
    }

    return transaction.isIncome ? 'Income' : 'Expense';
  }

  IconData _getIcon(TransactionModel transaction) {
    if (transaction.isIncome) {
      return Icons.account_balance_wallet;
    }

    final category = transaction.title.toLowerCase();

    if (category.contains('food') || category.contains('grocery')) {
      return Icons.restaurant;
    }

    if (category.contains('transport') ||
        category.contains('fuel') ||
        category.contains('uber')) {
      return Icons.directions_car;
    }

    if (category.contains('entertainment') || category.contains('movie')) {
      return Icons.movie;
    }

    return Icons.receipt_long;
  }
}
