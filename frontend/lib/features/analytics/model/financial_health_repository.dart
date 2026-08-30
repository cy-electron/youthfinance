import 'package:dio/dio.dart';

import '../model/financial_health_model.dart';

class FinancialHealthRepository {
  const FinancialHealthRepository();

  Future<FinancialHealthModel> getFinancialHealth() async {
    final response = await Dio().get('/financial-health');

    return FinancialHealthModel.fromJson(response.data as Map<String, dynamic>);
  }
}
