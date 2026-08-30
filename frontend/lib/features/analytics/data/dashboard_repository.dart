import 'dashboard_api_service.dart';
import 'dashboard_summary.dart';

class DashboardRepository {
  const DashboardRepository();

  Future<DashboardSummary> getDashboardSummary() {
    return DashboardApiService.getDashboardSummary();
  }
}
