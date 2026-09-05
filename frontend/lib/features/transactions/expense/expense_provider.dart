import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'expense_model.dart';
import 'expense_repository.dart';

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  return ExpenseRepository();
});

final expenseProvider =
    AsyncNotifierProvider<ExpenseNotifier, List<ExpenseModel>>(
  ExpenseNotifier.new,
);

class ExpenseNotifier extends AsyncNotifier<List<ExpenseModel>> {
  @override
  Future<List<ExpenseModel>> build() {
    return ref.read(expenseRepositoryProvider).getExpenses();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();

    try {
      final expenses =
          await ref.read(expenseRepositoryProvider).getExpenses();

      state = AsyncValue.data(expenses);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addExpense({
    required String category,
    required double amount,
    required DateTime date,
    String? description,
    String? sourceType,
    int? sourceId,
  }) async {
    final repository = ref.read(expenseRepositoryProvider);

    await repository.createExpense(
      category: category,
      amount: amount,
      date: date,
      description: description,
      sourceType: sourceType,
      sourceId: sourceId,
    );

    ref.invalidateSelf();
    await future;
  }

  Future<void> deleteExpense(int id) async {
    final repository = ref.read(expenseRepositoryProvider);

    await repository.deleteExpense(id);

    ref.invalidateSelf();
    await future;
  }
}