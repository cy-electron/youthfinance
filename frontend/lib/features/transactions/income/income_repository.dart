import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';
import 'income_model.dart';

class IncomeRepository {
  final Dio _dio = DioClient.instance;

  Future<List<IncomeModel>> getIncomes() async {
    final response = await _dio.get('/api/income');

    final responseData = response.data as Map<String, dynamic>;

    final data = responseData['data'] as List<dynamic>;

    return data
        .map((item) => IncomeModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<IncomeModel> getIncome(int id) async {
    final response = await _dio.get('/api/income/$id');

    final responseData = response.data as Map<String, dynamic>;

    return IncomeModel.fromJson(responseData['data'] as Map<String, dynamic>);
  }

  Future<IncomeModel> createIncome({
    required String source,
    required double amount,
    required DateTime date,
    String? description,
  }) async {
    final response = await _dio.post(
      '/api/income',
      data: {
        'source': source,
        'amount': amount.toStringAsFixed(2),
        'date': date.toIso8601String().split('T').first,
        'description': description,
      },
    );

    final responseData = response.data as Map<String, dynamic>;

    return IncomeModel.fromJson(responseData['data'] as Map<String, dynamic>);
  }

  Future<void> updateIncome(
    int id, {
    String? source,
    double? amount,
    DateTime? date,
    String? description,
  }) async {
    final Map<String, dynamic> data = {};

    if (source != null) {
      data['source'] = source;
    }

    if (amount != null) {
      data['amount'] = amount.toStringAsFixed(2);
    }

    if (date != null) {
      data['date'] = date.toIso8601String().split('T').first;
    }

    if (description != null) {
      data['description'] = description;
    }

    await _dio.put('/api/income/$id', data: data);
  }

  Future<void> deleteIncome(int id) async {
    await _dio.delete('/api/income/$id');
  }
}
