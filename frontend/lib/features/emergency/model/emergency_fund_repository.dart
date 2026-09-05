import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';

class EmergencyFundRepository {
  final Dio _dio = DioClient.instance;

  Future<double> getBalance() async {
    final response = await _dio.get('/api/emergency');

    final data = response.data as Map<String, dynamic>;
    final balance = data['data']['balance'];

    return double.parse(balance.toString());
  }

  Future<double> addMoney({required double amount, String? description}) async {
    return _moveMoney('/api/emergency/add', amount, description);
  }

  Future<double> releaseMoney({
    required double amount,
    String? description,
  }) async {
    return _moveMoney('/api/emergency/use', amount, description);
  }

  Future<double> _moveMoney(
    String endpoint,
    double amount,
    String? description,
  ) async {
    final response = await _dio.post(
      endpoint,
      data: {
        'amount': amount.toStringAsFixed(2),
        if (description != null && description.trim().isNotEmpty)
          'description': description.trim(),
      },
    );

    final data = response.data as Map<String, dynamic>;
    final balance = data['data']['balance'];

    return double.parse(balance.toString());
  }
}
