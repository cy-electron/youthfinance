import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/saving_repository.dart';
import 'saving_model.dart';

final savingRepositoryProvider = Provider<SavingRepository>(
  (ref) => SavingRepository(),
);

final savingProvider =
    StateNotifierProvider<SavingNotifier, AsyncValue<List<SavingModel>>>((ref) {
      return SavingNotifier(ref.read(savingRepositoryProvider));
    });

class SavingNotifier extends StateNotifier<AsyncValue<List<SavingModel>>> {
  final SavingRepository repository;

  SavingNotifier(this.repository) : super(const AsyncValue.loading()) {
    loadSavings();
  }

  Future<void> loadSavings() async {
    try {
      final savings = await repository.getSavings();

      state = AsyncValue.data(savings);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addSaving({
    int? goalId,
    required double amount,
    required DateTime date,
    String? description,
  }) async {
    await repository.createSaving(
      goalId: goalId,
      amount: amount,
      date: date,
      description: description,
    );

    await loadSavings();
  }

  Future<void> deleteSaving(int id) async {
    await repository.deleteSaving(id);

    await loadSavings();
  }
}
