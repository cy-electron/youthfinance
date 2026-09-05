import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'fun_fund_model.dart';
import 'fun_fund_repository.dart';

final funFundRepositoryProvider = Provider<FunFundRepository>((ref) {
  return FunFundRepository();
});

final funFundProvider =
    AsyncNotifierProvider<FunFundNotifier, List<FunFundModel>>(
  FunFundNotifier.new,
);

class FunFundNotifier extends AsyncNotifier<List<FunFundModel>> {
  @override
  Future<List<FunFundModel>> build() {
    return ref.read(funFundRepositoryProvider).getFunFunds();
  }

  // ------------------------------------------------------------
  // REFRESH
  // ------------------------------------------------------------

  Future<void> refresh() async {
    state = const AsyncValue.loading();

    try {
      final funds =
          await ref.read(funFundRepositoryProvider).getFunFunds();

      state = AsyncValue.data(funds);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  // ------------------------------------------------------------
  // CREATE
  // ------------------------------------------------------------

  Future<void> addFunFund({
    required int budgetId,
    required String title,
    required double targetAmount,
    DateTime? targetDate,
    String? notes,
  }) async {
    final repository = ref.read(funFundRepositoryProvider);

    await repository.createFunFund(
      budgetId: budgetId,
      title: title,
      targetAmount: targetAmount,
      targetDate: targetDate,
      notes: notes,
    );

    ref.invalidateSelf();
    await future;
  }

  // ------------------------------------------------------------
  // UPDATE
  // ------------------------------------------------------------

  Future<void> updateFunFund(
    int id, {
    String? title,
    double? targetAmount,
    DateTime? targetDate,
    String? notes,
  }) async {
    final repository = ref.read(funFundRepositoryProvider);

    await repository.updateFunFund(
      id,
      title: title,
      targetAmount: targetAmount,
      targetDate: targetDate,
      notes: notes,
    );

    ref.invalidateSelf();
    await future;
  }

  // ------------------------------------------------------------
  // DELETE
  // ------------------------------------------------------------

  Future<void> deleteFunFund(int id) async {
    final repository = ref.read(funFundRepositoryProvider);

    await repository.deleteFunFund(id);

    ref.invalidateSelf();
    await future;
  }
}