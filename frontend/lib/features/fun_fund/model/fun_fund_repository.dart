import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';
import 'fun_fund_model.dart';

class FunFundRepository {
  final Dio _dio = DioClient.instance;

  // ============================================================
  // GET ALL FUN FUNDS
  // ============================================================

  Future<List<FunFundModel>> getFunFunds() async {
    final response = await _dio.get('/api/fun-funds/');

    final responseData = response.data as Map<String, dynamic>;

    final data = responseData['data'] as List<dynamic>;

    return data
        .map(
          (item) => FunFundModel.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  // ============================================================
  // GET SINGLE FUN FUND
  // ============================================================

  Future<FunFundModel> getFunFund(int id) async {
    final response = await _dio.get('/api/fun-funds/$id');

    final responseData = response.data as Map<String, dynamic>;

    return FunFundModel.fromJson(
      responseData['data'] as Map<String, dynamic>,
    );
  }

  // ============================================================
  // CREATE FUN FUND
  // ============================================================

  Future<FunFundModel> createFunFund({
    required int budgetId,
    required String title,
    required double targetAmount,
    DateTime? targetDate,
    String? notes,
  }) async {
    final response = await _dio.post(
      '/api/fun-funds/',
      data: {
        'budget_id': budgetId,
        'title': title,
        'target_amount': targetAmount.toStringAsFixed(2),
        'target_date': targetDate != null
            ? targetDate.toIso8601String().split('T').first
            : null,
        'notes': notes,
      },
    );

    final responseData = response.data as Map<String, dynamic>;

    return FunFundModel.fromJson(
      responseData['data'] as Map<String, dynamic>,
    );
  }

  // ============================================================
  // UPDATE FUN FUND
  // ============================================================

  Future<FunFundModel> updateFunFund(
    int id, {
    String? title,
    double? targetAmount,
    DateTime? targetDate,
    String? notes,
  }) async {
    final Map<String, dynamic> data = {};

    if (title != null) {
      data['title'] = title;
    }

    if (targetAmount != null) {
      data['target_amount'] = targetAmount.toStringAsFixed(2);
    }

    if (targetDate != null) {
      data['target_date'] =
          targetDate.toIso8601String().split('T').first;
    }

    if (notes != null) {
      data['notes'] = notes;
    }

    final response = await _dio.put(
      '/api/fun-funds/$id',
      data: data,
    );

    final responseData = response.data as Map<String, dynamic>;

    return FunFundModel.fromJson(
      responseData['data'] as Map<String, dynamic>,
    );
  }

  // ============================================================
  // DELETE FUN FUND
  // ============================================================

  Future<void> deleteFunFund(int id) async {
    await _dio.delete('/api/fun-funds/$id');
  }
}