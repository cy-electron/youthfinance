import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youthfinance/features/goals/model/goal_repository.dart';

import '../model/goal_model.dart';

final goalRepositoryProvider = Provider<GoalRepository>((ref) {
  return GoalRepository();
});

final goalProvider = AsyncNotifierProvider<GoalNotifier, List<GoalModel>>(
  GoalNotifier.new,
);

class GoalNotifier extends AsyncNotifier<List<GoalModel>> {
  @override
  Future<List<GoalModel>> build() {
    return ref.read(goalRepositoryProvider).getGoals();
  }

  // ------------------------------------------------------------
  // REFRESH
  // ------------------------------------------------------------

  Future<void> refresh() async {
    state = const AsyncValue.loading();

    try {
      final goals = await ref.read(goalRepositoryProvider).getGoals();

      state = AsyncValue.data(goals);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  // ------------------------------------------------------------
  // CREATE
  // ------------------------------------------------------------
  // Creating a goal does NOT create or allocate money.
  //
  // current_amount always starts at 0.
  // Actual money allocation happens through Saving.
  // ------------------------------------------------------------

  Future<void> addGoal({
    required String title,
    required double targetAmount,
    required DateTime targetDate,
    String? description,
  }) async {
    final repository = ref.read(goalRepositoryProvider);

    await repository.createGoal(
      title: title,
      targetAmount: targetAmount,
      targetDate: targetDate,
      description: description,
    );

    ref.invalidateSelf();

    await future;
  }

  // ------------------------------------------------------------
  // UPDATE
  // ------------------------------------------------------------

  Future<void> updateGoal(
    int id, {
    String? title,
    double? targetAmount,
    double? currentAmount,
    DateTime? targetDate,
    String? description,
  }) async {
    final repository = ref.read(goalRepositoryProvider);

    await repository.updateGoal(
      id,
      title: title,
      targetAmount: targetAmount,
      currentAmount: currentAmount,
      targetDate: targetDate,
      description: description,
    );

    ref.invalidateSelf();

    await future;
  }

  // ------------------------------------------------------------
  // DELETE
  // ------------------------------------------------------------

  Future<void> deleteGoal(int id) async {
    final repository = ref.read(goalRepositoryProvider);

    await repository.deleteGoal(id);

    ref.invalidateSelf();

    await future;
  }
}
