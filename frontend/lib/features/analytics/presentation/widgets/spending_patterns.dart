import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'spending_patterns_provider.dart';
import 'pattern_card.dart';

class SpendingPatterns extends ConsumerWidget {
  const SpendingPatterns({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patternsState = ref.watch(spendingPatternsProvider);

    return patternsState.when(
      loading: () => const _PatternsLoading(),
      error: (error, stackTrace) => const _PatternsError(),
      data: (data) => GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.25,
        children: [
          PatternCard(
            title: 'Weekend',
            value: _formatPercentage(data.weekendChange),
            subtitle: data.weekendChange >= 0
                ? 'Higher than weekday'
                : 'Lower than weekday',
            color: data.weekendChange >= 0
                ? Colors.orange
                : Colors.green,
          ),

          PatternCard(
            title: 'Food',
            value: _formatPercentageOrEmpty(data.foodChange),
            subtitle: data.foodChange == null
                ? 'Not enough history'
                : data.foodChange! <= 0
                    ? 'Spending decreased'
                    : 'Spending increased',
            color: _changeColor(data.foodChange),
          ),

          PatternCard(
            title: 'Subscriptions',
            value: _formatPercentageOrEmpty(data.subscriptionChange),
            subtitle: data.subscriptionChange == null
                ? 'Not enough history'
                : data.subscriptionChange! <= 0
                    ? 'Spending decreased'
                    : 'Spending increased',
            color: _changeColor(data.subscriptionChange),
          ),

          PatternCard(
            title: 'Top Buy',
            value: data.topBuyAmount == null
                ? '—'
                : '₹${_formatAmount(data.topBuyAmount!)}',
            subtitle: data.topBuyTitle ?? 'No expenses yet',
            color: Colors.black,
          ),
        ],
      ),
    );
  }
}

String _formatPercentage(double value) {
  final rounded = value.round();

  if (rounded > 0) {
    return '+$rounded%';
  }

  return '$rounded%';
}

String _formatPercentageOrEmpty(double? value) {
  if (value == null) {
    return '—';
  }

  return _formatPercentage(value);
}

Color _changeColor(double? value) {
  if (value == null) {
    return Colors.grey;
  }

  return value <= 0 ? Colors.green : Colors.orange;
}

String _formatAmount(double amount) {
  return amount
      .round()
      .toString()
      .replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
        (match) => '${match.group(1)},',
      );
}

class _PatternsLoading extends StatelessWidget {
  const _PatternsLoading();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 300,
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class _PatternsError extends StatelessWidget {
  const _PatternsError();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 300,
      child: Center(
        child: Text('Unable to load spending patterns'),
      ),
    );
  }
}