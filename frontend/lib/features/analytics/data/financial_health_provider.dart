import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/financial_health_repository.dart';
import '../data/financial_health_summary.dart';

final financialHealthRepositoryProvider = Provider<FinancialHealthRepository>((
  ref,
) {
  return const FinancialHealthRepository();
});

final financialHealthProvider = FutureProvider<FinancialHealthSummary>((
  ref,
) async {
  final repository = ref.read(financialHealthRepositoryProvider);

  return repository.getFinancialHealth();
});
