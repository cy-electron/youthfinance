import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/auth_models.dart';
import '../data/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<UserModel?>>((ref) {
      return AuthNotifier(ref.read(authRepositoryProvider));
    });

class AuthNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AsyncValue.data(null));

  // ==========================================================
  // Login
  // ==========================================================

  Future<void> login({required String email, required String password}) async {
    state = const AsyncValue.loading();

    try {
      final user = await _repository.login(email: email, password: password);

      state = AsyncValue.data(user);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // ==========================================================
  // Register
  // ==========================================================

  Future<void> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();

    try {
      await _repository.register(
        fullName: fullName,
        email: email,
        password: password,
      );

      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // ==========================================================
  // Load current profile
  // ==========================================================

  Future<void> loadProfile() async {
    state = const AsyncValue.loading();

    try {
      final user = await _repository.getProfile();

      state = AsyncValue.data(user);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // ==========================================================
  // Update current profile
  // ==========================================================

  Future<void> updateProfile({
    required String fullName,
    required int age,
    required String gender,
    required String region,
    required String occupation,
  }) async {
    try {
      final updatedUser = await _repository.updateProfile(
        fullName: fullName,
        age: age,
        gender: gender,
        region: region,
        occupation: occupation,
      );

      // Immediately update the global auth/profile state.
      state = AsyncValue.data(updatedUser);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);

      // Let the Edit Profile screen handle the failure
      // and show an appropriate message.
      rethrow;
    }
  }

  // ==========================================================
  // Logout
  // ==========================================================

  Future<void> logout() async {
    await _repository.logout();

    state = const AsyncValue.data(null);
  }
}
