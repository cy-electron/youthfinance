import '../../../core/network/dio_client.dart';
import '../../../core/network/api_endpoints.dart';

import 'financial_health_model.dart';

class FinancialHealthApiService {
  FinancialHealthApiService._();

  static Future<FinancialHealthModel> getFinancialHealth() async {
    final response = await DioClient.instance.get(ApiEndpoints.financialHealth);

    print('FINANCIAL HEALTH API RESPONSE: ${response.data}');

    final data = response.data['data'];

    return FinancialHealthModel.fromJson(data);
  }
}
