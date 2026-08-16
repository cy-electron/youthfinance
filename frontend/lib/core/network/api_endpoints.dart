class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = 'http://192.168.0.105:5000';

  static const String health = '/';

  static const String register = '/api/auth/register';
  static const String login = '/api/auth/login';
  static const String profile = '/api/auth/profile';

  static const String incomes = '/api/income';
  static const String expenses = '/api/expense';
  static const String goals = '/api/goal/';
  static const String budget = '/api/budget/';
  static const String dashboard = '/api/dashboard/summary';
  static const String financialHealth = '/api/financial-health/';
  static const String spendingAnalysis = '/api/spending-analysis/';
  static const String investments = '/api/investments/';
  static const String funFunds = '/api/fun-funds/';
}
