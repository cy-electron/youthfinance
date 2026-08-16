import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'income_model.dart';
import 'income_repository.dart';

final incomeRepositoryProvider = Provider<IncomeRepository>((ref) {
  return IncomeRepository();
});

final incomeProvider = AsyncNotifierProvider<IncomeNotifier, List<IncomeModel>>(
  IncomeNotifier.new,
);

class IncomeNotifier extends AsyncNotifier<List<IncomeModel>> {
  @override
  Future<List<IncomeModel>> build() {
    return ref.read(incomeRepositoryProvider).getIncomes();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();

    try {
      final incomes = await ref.read(incomeRepositoryProvider).getIncomes();

      state = AsyncValue.data(incomes);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addIncome({
    required String source,
    required double amount,
    required DateTime date,
    String? description,
  }) async {
    final repository = ref.read(incomeRepositoryProvider);

    await repository.createIncome(
      source: source,
      amount: amount,
      date: date,
      description: description,
    );

    ref.invalidateSelf();
    await future;
  }

  Future<void> deleteIncome(int id) async {
    final repository = ref.read(incomeRepositoryProvider);

    await repository.deleteIncome(id);

    ref.invalidateSelf();
    await future;
  }
}
