import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youthfinance/features/transactions/expense/expense_provider.dart';
import 'package:youthfinance/features/transactions/income/income_provider.dart';
import 'package:youthfinance/features/transactions/model/transaction_model.dart';

final transactionProvider = Provider<AsyncValue<List<TransactionModel>>>((ref) {
  final incomeState = ref.watch(incomeProvider);
  final expenseState = ref.watch(expenseProvider);

  // If either API is loading, keep the transaction screen loading.
  if (incomeState.isLoading || expenseState.isLoading) {
    return const AsyncValue.loading();
  }

  // If income failed, expose that error.
  if (incomeState.hasError) {
    return AsyncValue.error(
      incomeState.error!,
      incomeState.stackTrace ?? StackTrace.current,
    );
  }

  // If expense failed, expose that error.
  if (expenseState.hasError) {
    return AsyncValue.error(
      expenseState.error!,
      expenseState.stackTrace ?? StackTrace.current,
    );
  }

  final incomes = incomeState.value ?? [];
  final expenses = expenseState.value ?? [];

  final transactions = <TransactionModel>[
    ...incomes.map(
      (income) => TransactionModel(
        id: income.id,
        type: TransactionType.income,
        title: income.source,
        description: income.description,
        amount: income.amount,
        date: income.date,
      ),
    ),
    ...expenses.map(
      (expense) => TransactionModel(
        id: expense.id,
        type: TransactionType.expense,
        title: expense.category,
        description: expense.description,
        amount: expense.amount,
        date: expense.date,
      ),
    ),
  ];

  // Newest transactions first.
  transactions.sort((a, b) => b.date.compareTo(a.date));

  return AsyncValue.data(transactions);
});
