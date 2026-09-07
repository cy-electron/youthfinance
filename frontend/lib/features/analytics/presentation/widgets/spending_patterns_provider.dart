import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:youthfinance/features/transactions/model/transaction_model.dart';
import 'package:youthfinance/features/transactions/model/transaction_provider.dart';

class SpendingPatternData {
  final double weekendChange;
  final double? foodChange;
  final double? subscriptionChange;

  final double? topBuyAmount;
  final String? topBuyTitle;

  const SpendingPatternData({
    required this.weekendChange,
    required this.foodChange,
    required this.subscriptionChange,
    required this.topBuyAmount,
    required this.topBuyTitle,
  });
}

final spendingPatternsProvider =
    Provider<AsyncValue<SpendingPatternData>>((ref) {
  final transactionsState = ref.watch(transactionProvider);

  if (transactionsState.isLoading) {
    return const AsyncValue.loading();
  }

  if (transactionsState.hasError) {
    return AsyncValue.error(
      transactionsState.error!,
      transactionsState.stackTrace ?? StackTrace.current,
    );
  }

  final transactions = transactionsState.value ?? [];

  final expenses = transactions.where((t) => !t.isIncome).toList();

  if (expenses.isEmpty) {
    return const AsyncValue.data(
      SpendingPatternData(
        weekendChange: 0,
        foodChange: null,
        subscriptionChange: null,
        topBuyAmount: null,
        topBuyTitle: null,
      ),
    );
  }

  final now = DateTime.now();

  final currentMonthExpenses = expenses.where((transaction) {
    return transaction.date.year == now.year &&
        transaction.date.month == now.month;
  }).toList();

  final previousMonth = DateTime(now.year, now.month - 1);

  final previousMonthExpenses = expenses.where((transaction) {
    return transaction.date.year == previousMonth.year &&
        transaction.date.month == previousMonth.month;
  }).toList();

  final weekendChange = _calculateWeekendChange(expenses);

  final foodChange = _calculateCategoryChange(
    currentMonthExpenses,
    previousMonthExpenses,
    _isFood,
  );

  final subscriptionChange = _calculateCategoryChange(
    currentMonthExpenses,
    previousMonthExpenses,
    _isSubscription,
  );

  final topBuy = expenses.reduce(
    (current, next) =>
        next.amount > current.amount ? next : current,
  );

  return AsyncValue.data(
    SpendingPatternData(
      weekendChange: weekendChange,
      foodChange: foodChange,
      subscriptionChange: subscriptionChange,
      topBuyAmount: topBuy.amount,
      topBuyTitle: _topBuyLabel(topBuy),
    ),
  );
});

double _calculateWeekendChange(
  List<TransactionModel> expenses,
) {
  final weekendDailyTotals = <DateTime, double>{};
  final weekdayDailyTotals = <DateTime, double>{};

  for (final transaction in expenses) {
    final date = DateTime(
      transaction.date.year,
      transaction.date.month,
      transaction.date.day,
    );

    final isWeekend =
        transaction.date.weekday == DateTime.saturday ||
        transaction.date.weekday == DateTime.sunday;

    if (isWeekend) {
      weekendDailyTotals[date] =
          (weekendDailyTotals[date] ?? 0) + transaction.amount;
    } else {
      weekdayDailyTotals[date] =
          (weekdayDailyTotals[date] ?? 0) + transaction.amount;
    }
  }

  if (weekendDailyTotals.isEmpty || weekdayDailyTotals.isEmpty) {
    return 0;
  }

  final weekendAverage =
      weekendDailyTotals.values.reduce((a, b) => a + b) /
      weekendDailyTotals.length;

  final weekdayAverage =
      weekdayDailyTotals.values.reduce((a, b) => a + b) /
      weekdayDailyTotals.length;

  if (weekdayAverage == 0) {
    return 0;
  }

  return ((weekendAverage - weekdayAverage) / weekdayAverage) * 100;
}

double? _calculateCategoryChange(
  List<TransactionModel> currentMonth,
  List<TransactionModel> previousMonth,
  bool Function(TransactionModel) matcher,
) {
  final currentTotal = currentMonth
      .where(matcher)
      .fold<double>(0, (sum, transaction) => sum + transaction.amount);

  final previousTotal = previousMonth
      .where(matcher)
      .fold<double>(0, (sum, transaction) => sum + transaction.amount);

  // No previous data means a percentage comparison is not meaningful.
  if (previousTotal == 0) {
    return null;
  }

  return ((currentTotal - previousTotal) / previousTotal) * 100;
}

bool _isFood(TransactionModel transaction) {
  final category = transaction.category.toLowerCase();

  return category.contains('food') ||
      category.contains('restaurant') ||
      category.contains('dining') ||
      category.contains('grocery');
}

bool _isSubscription(TransactionModel transaction) {
  final category = transaction.category.toLowerCase();

  return category.contains('subscription') ||
      category.contains('netflix') ||
      category.contains('spotify') ||
      category.contains('prime');
}

String _topBuyLabel(TransactionModel transaction) {
  if (transaction.description != null &&
      transaction.description!.trim().isNotEmpty) {
    return transaction.description!.trim();
  }

  return transaction.title;
}