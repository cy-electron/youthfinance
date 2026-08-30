import 'financial_health_api_service.dart';
import 'financial_health_summary.dart';

class FinancialHealthRepository {
  const FinancialHealthRepository();

  Future<FinancialHealthSummary> getFinancialHealth() {
    return FinancialHealthApiService.getFinancialHealth();
  }
}
