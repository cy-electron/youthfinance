class DashboardSummary {
  final double totalIncome;
  final double totalExpense;
  final double netSavings;
  final double monthlyBudget;
  final int activeGoals;
  final int completedGoals;

  const DashboardSummary({
    required this.totalIncome,
    required this.totalExpense,
    required this.netSavings,
    required this.monthlyBudget,
    required this.activeGoals,
    required this.completedGoals,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      totalIncome: (json['total_income'] ?? 0).toDouble(),
      totalExpense: (json['total_expense'] ?? 0).toDouble(),
      netSavings: (json['net_savings'] ?? 0).toDouble(),
      monthlyBudget: (json['monthly_budget'] ?? 0).toDouble(),
      activeGoals: (json['active_goals'] ?? 0) as int,
      completedGoals: (json['completed_goals'] ?? 0) as int,
    );
  }
}
