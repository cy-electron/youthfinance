import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youthfinance/features/analytics/data/dashboard_repository.dart';
import 'package:youthfinance/features/analytics/data/dashboard_summary.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return const DashboardRepository();
});

final dashboardProvider = FutureProvider<DashboardSummary>((ref) async {
  final repository = ref.read(dashboardRepositoryProvider);

  return repository.getDashboardSummary();
});
