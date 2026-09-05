import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'emergency_fund_repository.dart';
import '../../notifications/model/notification_provider.dart';

final emergencyFundRepositoryProvider = Provider<EmergencyFundRepository>((ref) {
  return EmergencyFundRepository();
});

final emergencyFundProvider =
    AsyncNotifierProvider<EmergencyFundNotifier, double>(
      EmergencyFundNotifier.new,
    );

class EmergencyFundNotifier extends AsyncNotifier<double> {
  @override
  Future<double> build() {
    return ref.read(emergencyFundRepositoryProvider).getBalance();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      state = AsyncValue.data(
        await ref.read(emergencyFundRepositoryProvider).getBalance(),
      );
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addMoney({required double amount, String? description}) async {
    final balance = await ref
        .read(emergencyFundRepositoryProvider)
        .addMoney(amount: amount, description: description);
    state = AsyncValue.data(balance);
    ref.invalidate(notificationProvider);
    ref.invalidate(unreadNotificationCountProvider);
  }

  Future<void> releaseMoney({
    required double amount,
    String? description,
  }) async {
    final balance = await ref
        .read(emergencyFundRepositoryProvider)
        .releaseMoney(amount: amount, description: description);
    state = AsyncValue.data(balance);
    ref.invalidate(notificationProvider);
    ref.invalidate(unreadNotificationCountProvider);
  }
}
