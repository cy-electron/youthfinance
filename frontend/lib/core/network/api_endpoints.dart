class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = 'https://youthfinance.onrender.com';

  // Health
  static const String health = '/';

  // Authentication
  static const String register = '/api/auth/register';
  static const String login = '/api/auth/login';
  static const String profile = '/api/auth/profile';

  // Core Financial Modules
  static const String incomes = '/api/income';
  static const String expenses = '/api/expense';
  static const String goals = '/api/goal/';
  static const String budget = '/api/budget/';

  // Analytics
  static const String dashboard = '/api/dashboard/summary';
  static const String financialHealth = '/api/financial-health/';
  static const String spendingAnalysis = '/api/spending-analysis/';

  // Investments & Fun Fund
  static const String investments = '/api/investments/';
  static const String funFunds = '/api/fun-funds/';

  // Notifications
  static const String notifications = '/api/notifications';
}