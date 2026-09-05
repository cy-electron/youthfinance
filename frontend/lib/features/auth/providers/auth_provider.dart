import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:youthfinance/features/analytics/data/financial_health_provider.dart';
import 'package:youthfinance/features/analytics/presentation/screens/dashboard_provider.dart';
import 'package:youthfinance/features/budget/budget_provider.dart';
import 'package:youthfinance/features/goals/model/goal_provider.dart';
import 'package:youthfinance/features/transactions/model/transaction_provider.dart';
import 'package:youthfinance/features/emergency/model/emergency_fund_provider.dart';
import 'package:youthfinance/features/investment/model/investment_provider.dart';
import 'package:youthfinance/features/notifications/model/notification_provider.dart';
import 'package:youthfinance/features/transactions/expense/expense_provider.dart';
import 'package:youthfinance/features/transactions/income/income_provider.dart';
import 'package:youthfinance/features/fun_fund/model/fun_fund_provider.dart';

import '../../../core/storage/secure_storage.dart';
import '../data/auth_models.dart';
import '../data/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<UserModel?>>((ref) {
      return AuthNotifier(ref, ref.read(authRepositoryProvider));
    });

class AuthNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final Ref _ref;
  final AuthRepository _repository;

  AuthNotifier(this._ref, this._repository)
    : super(const AsyncValue.loading()) {
    _restoreSession();
  }

  // ==========================================================
  // Restore persisted session
  // ==========================================================

  Future<void> _restoreSession() async {
    try {
      final hasToken = await SecureStorage.hasAccessToken();

      if (!hasToken) {
        state = const AsyncValue.data(null);
        return;
      }

      final user = await _repository.getProfile();

      state = AsyncValue.data(user);
    } on DioException catch (e, stackTrace) {
      // Only remove the token when the backend explicitly tells us
      // that authentication is invalid/expired.
      if (e.response?.statusCode == 401) {
        await SecureStorage.deleteAccessToken();
        state = const AsyncValue.data(null);
        return;
      }

      // Network/server/timeout errors should NOT destroy a valid session.
      state = AsyncValue.error(e, stackTrace);
    } catch (e, stackTrace) {
      // Unexpected error: keep the token and expose the error.
      state = AsyncValue.error(e, stackTrace);
    }
  }

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

      state = AsyncValue.data(updatedUser);
    } catch (_) {
      rethrow;
    }
  }

  // ==========================================================
  // Logout
  // ==========================================================

  Future<void> logout() async {
    await _repository.logout();

    // Clear all account-specific cached/provider data.
    _ref.invalidate(financialHealthProvider);
    _ref.invalidate(dashboardProvider);

    _ref.invalidate(budgetProvider);
    _ref.invalidate(goalProvider);

    // Transactions are composed from these two providers.
    _ref.invalidate(incomeProvider);
    _ref.invalidate(expenseProvider);
    _ref.invalidate(transactionProvider);

    _ref.invalidate(emergencyFundProvider);
    _ref.invalidate(investmentProvider);

    _ref.invalidate(funFundProvider);

    _ref.invalidate(notificationProvider);
    _ref.invalidate(unreadNotificationCountProvider);
    _ref.invalidate(notificationPreferenceProvider);

    // Finally clear authenticated user.
    state = const AsyncValue.data(null);
  }
}
