import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'investment_model.dart';
import 'investment_repository.dart';

final investmentRepositoryProvider = Provider<InvestmentRepository>((ref) {
  return InvestmentRepository();
});

final investmentProvider =
    AsyncNotifierProvider<InvestmentNotifier, List<InvestmentModel>>(
      InvestmentNotifier.new,
    );

class InvestmentNotifier extends AsyncNotifier<List<InvestmentModel>> {
  @override
  Future<List<InvestmentModel>> build() {
    return ref.read(investmentRepositoryProvider).getInvestments();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      state = AsyncValue.data(
        await ref.read(investmentRepositoryProvider).getInvestments(),
      );
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addInvestment({
    required String type,
    required String name,
    required double amount,
    double? currentValue,
    required DateTime date,
    String? notes,
  }) async {
    await ref
        .read(investmentRepositoryProvider)
        .createInvestment(
          type: type,
          name: name,
          amount: amount,
          currentValue: currentValue,
          date: date,
          notes: notes,
        );
    await refresh();
  }

  Future<void> deleteInvestment(int id) async {
    await ref.read(investmentRepositoryProvider).deleteInvestment(id);
    await refresh();
  }
}
