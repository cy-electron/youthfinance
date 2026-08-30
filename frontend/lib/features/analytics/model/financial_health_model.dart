class FinancialHealthModel {
  final int score;
  final FinancialHealthBreakdown breakdown;

  const FinancialHealthModel({required this.score, required this.breakdown});

  factory FinancialHealthModel.fromJson(Map<String, dynamic> json) {
    final breakdownJson = json['breakdown'] as Map<String, dynamic>? ?? {};

    return FinancialHealthModel(
      score: (json['score'] as num?)?.round() ?? 0,
      breakdown: FinancialHealthBreakdown.fromJson(breakdownJson),
    );
  }
}

class FinancialHealthBreakdown {
  final double savings;
  final double budget;
  final double goals;
  final double income;
  final double expense;
  final double emergency;
  final double investment;
  final double funFund;

  const FinancialHealthBreakdown({
    required this.savings,
    required this.budget,
    required this.goals,
    required this.income,
    required this.expense,
    required this.emergency,
    required this.investment,
    required this.funFund,
  });

  factory FinancialHealthBreakdown.fromJson(Map<String, dynamic> json) {
    double value(String key) {
      return (json[key] as num?)?.toDouble() ?? 0;
    }

    return FinancialHealthBreakdown(
      savings: value('savings'),
      budget: value('budget'),
      goals: value('goals'),
      income: value('income'),
      expense: value('expense'),
      emergency: value('emergency'),
      investment: value('investment'),
      funFund: value('fun_fund'),
    );
  }
}
