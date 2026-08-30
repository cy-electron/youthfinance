import '../../../core/network/api_endpoints.dart';
import '../../../core/network/dio_client.dart';

import 'financial_health_summary.dart';

class FinancialHealthApiService {
  FinancialHealthApiService._();

  static Future<FinancialHealthSummary> getFinancialHealth() async {
    final response = await DioClient.instance.get(ApiEndpoints.financialHealth);

    print('FINANCIAL HEALTH API RESPONSE: ${response.data}');

    final responseData = response.data;

    if (responseData is! Map) {
      throw Exception('Invalid financial health response');
    }

    final data = responseData['data'];

    if (data is! Map) {
      throw Exception('Financial health data is missing');
    }

    return FinancialHealthSummary.fromJson(Map<String, dynamic>.from(data));
  }
}
