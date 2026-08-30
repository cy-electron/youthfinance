import 'package:dio/dio.dart';

import '../../core/network/dio_client.dart';
import 'budget_model.dart';

class BudgetRepository {
  final Dio _dio = DioClient.instance;

  // ------------------------------------------------------------
  // GET ALL BUDGETS
  // ------------------------------------------------------------

  Future<List<BudgetModel>> getBudgets() async {
    final response = await _dio.get('/api/budget/');

    final responseData = response.data as Map<String, dynamic>;

    final data = responseData['data'] as List<dynamic>;

    return data
        .map((item) => BudgetModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  // ------------------------------------------------------------
  // GET SINGLE BUDGET
  // ------------------------------------------------------------

  Future<BudgetModel> getBudget(int id) async {
    final response = await _dio.get('/api/budget/$id');

    final responseData = response.data as Map<String, dynamic>;

    return BudgetModel.fromJson(responseData['data'] as Map<String, dynamic>);
  }

  // ------------------------------------------------------------
  // CREATE BUDGET
  // ------------------------------------------------------------

  Future<int> createBudget({
    required String category,
    required double amount,
    required int month,
    required int year,
  }) async {
    final response = await _dio.post(
      '/api/budget/',
      data: {
        'category': category,
        'amount': amount.toStringAsFixed(2),
        'month': month,
        'year': year,
      },
    );

    final responseData = response.data as Map<String, dynamic>;

    final data = responseData['data'] as Map<String, dynamic>;

    return data['id'] as int;
  }

  // ------------------------------------------------------------
  // UPDATE BUDGET
  // ------------------------------------------------------------

  Future<void> updateBudget(
    int id, {
    String? category,
    double? amount,
    int? month,
    int? year,
  }) async {
    final Map<String, dynamic> data = {};

    if (category != null) {
      data['category'] = category;
    }

    if (amount != null) {
      data['amount'] = amount.toStringAsFixed(2);
    }

    if (month != null) {
      data['month'] = month;
    }

    if (year != null) {
      data['year'] = year;
    }

    await _dio.put('/api/budget/$id', data: data);
  }

  // ------------------------------------------------------------
  // DELETE BUDGET
  // ------------------------------------------------------------

  Future<void> deleteBudget(int id) async {
    await _dio.delete('/api/budget/$id');
  }
}
