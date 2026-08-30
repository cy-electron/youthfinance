class BudgetModel {
  final int id;
  final String category;
  final double amount;
  final int month;
  final int year;

  const BudgetModel({
    required this.id,
    required this.category,
    required this.amount,
    required this.month,
    required this.year,
  });

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      id: json['id'] as int,
      category: json['category'] as String,
      amount: (json['amount'] as num).toDouble(),
      month: json['month'] as int,
      year: json['year'] as int,
    );
  }
}
