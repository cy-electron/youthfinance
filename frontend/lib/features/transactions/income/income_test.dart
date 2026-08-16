import 'income_repository.dart';

Future<void> testIncomeIntegration() async {
  final repository = IncomeRepository();

  try {
    print('--- YouthFinance INCOME TEST ---');

    final incomes = await repository.getIncomes();

    print('INCOME REQUEST SUCCESS');
    print('TOTAL INCOMES: ${incomes.length}');

    for (final income in incomes) {
      print(
        'Income: ${income.source} | '
        '₹${income.amount} | '
        '${income.date.toIso8601String()}',
      );
    }
  } catch (e) {
    print('INCOME TEST FAILED: $e');
  }
}
