import '../../../core/network/dio_client.dart';
import '../model/saving_model.dart';

class SavingRepository {
  final _dio = DioClient.instance;

  Future<List<SavingModel>> getSavings() async {
    final response = await _dio.get('/api/saving');

    final data = response.data['data'] as List;

    return data
        .map((item) => SavingModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<SavingModel> createSaving({
    int? goalId,
    required double amount,
    required DateTime date,
    String? description,
  }) async {
    final response = await _dio.post(
      '/api/saving',
      data: {
        'goal_id': goalId,
        'amount': amount,
        'date': date.toIso8601String().split('T').first,
        'description': description,
      },
    );

    return SavingModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<void> deleteSaving(int id) async {
    await _dio.delete('/api/saving/$id');
  }
}
