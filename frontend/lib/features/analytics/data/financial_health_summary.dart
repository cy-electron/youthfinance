class FinancialHealthSummary {
  final double score;

  final double savings;
  final double budget;
  final double goals;
  final double income;
  final double expense;
  final double emergency;
  final double investment;
  final double funFund;

  const FinancialHealthSummary({
    required this.score,
    required this.savings,
    required this.budget,
    required this.goals,
    required this.income,
    required this.expense,
    required this.emergency,
    required this.investment,
    required this.funFund,
  });

  factory FinancialHealthSummary.fromJson(Map<String, dynamic> json) {
    final breakdown = json['breakdown'] is Map
        ? Map<String, dynamic>.from(json['breakdown'] as Map)
        : <String, dynamic>{};

    return FinancialHealthSummary(
      score: _toDouble(json['score']),
      savings: _toDouble(breakdown['savings']),
      budget: _toDouble(breakdown['budget']),
      goals: _toDouble(breakdown['goals']),
      income: _toDouble(breakdown['income']),
      expense: _toDouble(breakdown['expense']),
      emergency: _toDouble(breakdown['emergency']),
      investment: _toDouble(breakdown['investment']),
      funFund: _toDouble(breakdown['fun_fund']),
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) {
      return 0;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString()) ?? 0;
  }
}
