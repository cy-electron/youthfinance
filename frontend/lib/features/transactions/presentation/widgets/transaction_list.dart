import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:youthfinance/features/transactions/model/transaction_filter.dart';
import 'package:youthfinance/features/transactions/model/transaction_model.dart';
import 'package:youthfinance/features/transactions/model/transaction_provider.dart';

import 'transaction_group.dart';
import 'transaction_tile.dart';

class TransactionList extends ConsumerWidget {
  final TransactionFilter filter;

  const TransactionList({super.key, required this.filter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionState = ref.watch(transactionProvider);

    return transactionState.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      ),

      error: (error, stackTrace) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Icon(Icons.error_outline, size: 40),
              const SizedBox(height: 12),
              const Text(
                'Unable to load transactions',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(error.toString(), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),

      data: (transactions) {
        // Apply selected filter
        final filteredTransactions = _applyFilter(transactions);

        // No results for selected filter
        if (filteredTransactions.isEmpty) {
          return _EmptyState(filter: filter);
        }

        // Group filtered transactions by date
        final grouped = _groupTransactions(filteredTransactions);

        return Column(
          children: grouped.entries.map((entry) {
            return TransactionGroup(
              title: entry.key,
              transactions: entry.value.map((transaction) {
                return TransactionTile(
                  icon: _getIcon(transaction),
                  title: transaction.title,
                  subtitle: _buildSubtitle(transaction),
                  amount: transaction.amount,
                  isIncome: transaction.isIncome,
                );
              }).toList(),
            );
          }).toList(),
        );
      },
    );
  }

  // ------------------------------------------------------------
  // FILTERING
  // ------------------------------------------------------------

  List<TransactionModel> _applyFilter(List<TransactionModel> transactions) {
    switch (filter) {
      case TransactionFilter.all:
        return transactions;

      case TransactionFilter.income:
        return transactions
            .where((transaction) => transaction.isIncome)
            .toList();

      case TransactionFilter.expense:
        return transactions
            .where((transaction) => !transaction.isIncome)
            .toList();

      case TransactionFilter.investments:
        // Investment transactions are not currently
        // represented in TransactionModel.
        return [];
    }
  }

  // ------------------------------------------------------------
  // GROUPING
  // ------------------------------------------------------------

  Map<String, List<TransactionModel>> _groupTransactions(
    List<TransactionModel> transactions,
  ) {
    final groups = <String, List<TransactionModel>>{};

    for (final transaction in transactions) {
      final key = _groupTitle(transaction.date);

      groups.putIfAbsent(key, () => []);
      groups[key]!.add(transaction);
    }

    return groups;
  }

  String _groupTitle(DateTime date) {
    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);

    final transactionDate = DateTime(date.year, date.month, date.day);

    final difference = today.difference(transactionDate).inDays;

    if (difference == 0) {
      return 'Today';
    }

    if (difference == 1) {
      return 'Yesterday';
    }

    return '${date.day}/${date.month}/${date.year}';
  }

  // ------------------------------------------------------------
  // SUBTITLE
  // ------------------------------------------------------------

  String _buildSubtitle(TransactionModel transaction) {
    if (transaction.description != null &&
        transaction.description!.trim().isNotEmpty) {
      return transaction.description!;
    }

    return transaction.isIncome ? 'Income' : 'Expense';
  }

  // ------------------------------------------------------------
  // ICON
  // ------------------------------------------------------------

  IconData _getIcon(TransactionModel transaction) {
    if (transaction.isIncome) {
      return Icons.account_balance_wallet;
    }

    final category = transaction.title.toLowerCase();

    if (category.contains('food') ||
        category.contains('grocery') ||
        category.contains('restaurant')) {
      return Icons.restaurant;
    }

    if (category.contains('transport') ||
        category.contains('fuel') ||
        category.contains('uber')) {
      return Icons.directions_car;
    }

    if (category.contains('entertainment') ||
        category.contains('movie') ||
        category.contains('netflix')) {
      return Icons.movie;
    }

    return Icons.receipt_long;
  }
}

// ------------------------------------------------------------
// EMPTY STATE
// ------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  final TransactionFilter filter;

  const _EmptyState({required this.filter});

  String get message {
    switch (filter) {
      case TransactionFilter.all:
        return 'No transactions yet.';

      case TransactionFilter.income:
        return 'No income transactions.';

      case TransactionFilter.expense:
        return 'No expense transactions.';

      case TransactionFilter.investments:
        return 'No investment transactions.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(message, textAlign: TextAlign.center),
      ),
    );
  }
}
