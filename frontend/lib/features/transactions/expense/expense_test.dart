import 'expense_repository.dart';

Future<void> testExpenseIntegration() async {
  final repository = ExpenseRepository();

  try {
    print('--- YouthFinance EXPENSE TEST ---');

    final expenses = await repository.getExpenses();

    print('EXPENSE REQUEST SUCCESS');
    print('TOTAL EXPENSES: ${expenses.length}');

    for (final expense in expenses) {
      print(
        'Expense: ${expense.category} | '
        '₹${expense.amount} | '
        '${expense.date.toIso8601String()}',
      );
    }
  } catch (e) {
    print('EXPENSE TEST FAILED: $e');
  }
}
