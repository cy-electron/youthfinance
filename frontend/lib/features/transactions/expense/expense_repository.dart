import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';
import 'expense_model.dart';

class ExpenseRepository {
  final Dio _dio = DioClient.instance;

  Future<List<ExpenseModel>> getExpenses() async {
    final response = await _dio.get('/api/expense');

    final responseData = response.data as Map<String, dynamic>;

    final data = responseData['data'] as List<dynamic>;

    return data
        .map((item) => ExpenseModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<ExpenseModel> getExpense(int id) async {
    final response = await _dio.get('/api/expense/$id');

    final responseData = response.data as Map<String, dynamic>;

    return ExpenseModel.fromJson(responseData['data'] as Map<String, dynamic>);
  }

  Future<ExpenseModel> createExpense({
    required String category,
    required double amount,
    required DateTime date,
    String? description,
  }) async {
    final response = await _dio.post(
      '/api/expense',
      data: {
        'category': category,
        'amount': amount,
        'date': date.toIso8601String().split('T').first,
        'description': description,
      },
    );

    final responseData = response.data as Map<String, dynamic>;

    final id = (responseData['data']['id'] as num).toInt();

    return ExpenseModel(
      id: id,
      category: category,
      amount: amount,
      date: date,
      description: description,
    );
  }

  Future<void> updateExpense(
    int id, {
    String? category,
    double? amount,
    DateTime? date,
    String? description,
  }) async {
    final Map<String, dynamic> data = {};

    if (category != null) {
      data['category'] = category;
    }

    if (amount != null) {
      data['amount'] = amount;
    }

    if (date != null) {
      data['date'] = date.toIso8601String().split('T').first;
    }

    if (description != null) {
      data['description'] = description;
    }

    await _dio.put('/api/expense/$id', data: data);
  }

  Future<void> deleteExpense(int id) async {
    await _dio.delete('/api/expense/$id');
  }
}
