import 'package:dio/dio.dart';

import '../../../core/network/api_endpoints.dart';
import '../../../core/network/dio_client.dart';
import 'investment_model.dart';

class InvestmentRepository {
  final Dio _dio = DioClient.instance;

  Future<List<InvestmentModel>> getInvestments() async {
    final response = await _dio.get(ApiEndpoints.investments);
    final data = response.data as Map<String, dynamic>;
    return (data['data'] as List<dynamic>)
        .map((item) => InvestmentModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<InvestmentModel> createInvestment({
    required String type,
    required String name,
    required double amount,
    double? currentValue,
    required DateTime date,
    String? notes,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.investments,
      data: {
        'investment_type': type,
        'investment_name': name.trim(),
        'amount': amount.toStringAsFixed(2),
        if (currentValue != null)
          'current_value': currentValue.toStringAsFixed(2),
        'investment_date': date.toIso8601String().split('T').first,
        if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
      },
    );
    final data = response.data as Map<String, dynamic>;
    return InvestmentModel.fromJson(data['data'] as Map<String, dynamic>);
  }

  Future<void> deleteInvestment(int id) async {
    await _dio.delete('${ApiEndpoints.investments}$id');
  }
}
