import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'budget_model.dart';
import 'budget_repository.dart';

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  return BudgetRepository();
});

final budgetProvider = AsyncNotifierProvider<BudgetNotifier, List<BudgetModel>>(
  BudgetNotifier.new,
);

class BudgetNotifier extends AsyncNotifier<List<BudgetModel>> {
  @override
  Future<List<BudgetModel>> build() {
    return ref.read(budgetRepositoryProvider).getBudgets();
  }

  // ------------------------------------------------------------
  // REFRESH
  // ------------------------------------------------------------

  Future<void> refresh() async {
    state = const AsyncValue.loading();

    try {
      final budgets = await ref.read(budgetRepositoryProvider).getBudgets();

      state = AsyncValue.data(budgets);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  // ------------------------------------------------------------
  // CREATE
  // ------------------------------------------------------------

  Future<void> addBudget({
    required String category,
    required double amount,
    required int month,
    required int year,
  }) async {
    final repository = ref.read(budgetRepositoryProvider);

    await repository.createBudget(
      category: category,
      amount: amount,
      month: month,
      year: year,
    );

    ref.invalidateSelf();
    await future;
  }

  // ------------------------------------------------------------
  // UPDATE
  // ------------------------------------------------------------

  Future<void> updateBudget(
    int id, {
    String? category,
    double? amount,
    int? month,
    int? year,
  }) async {
    final repository = ref.read(budgetRepositoryProvider);

    await repository.updateBudget(
      id,
      category: category,
      amount: amount,
      month: month,
      year: year,
    );

    ref.invalidateSelf();
    await future;
  }

  // ------------------------------------------------------------
  // DELETE
  // ------------------------------------------------------------

  Future<void> deleteBudget(int id) async {
    final repository = ref.read(budgetRepositoryProvider);

    await repository.deleteBudget(id);

    ref.invalidateSelf();
    await future;
  }
}
