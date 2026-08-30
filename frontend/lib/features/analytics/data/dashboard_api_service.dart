import '../../../core/network/dio_client.dart';
import '../../../core/network/api_endpoints.dart';

import 'dashboard_summary.dart';

class DashboardApiService {
  DashboardApiService._();

  static Future<DashboardSummary> getDashboardSummary() async {
    final response = await DioClient.instance.get(ApiEndpoints.dashboard);

    print('DASHBOARD API RESPONSE: ${response.data}');

    final data = response.data['data'];

    return DashboardSummary.fromJson(data);
  }
}
