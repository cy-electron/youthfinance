class ExpenseModel {
  final int id;
  final String category;
  final double amount;
  final DateTime date;
  final String? description;

  const ExpenseModel({
    required this.id,
    required this.category,
    required this.amount,
    required this.date,
    this.description,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'] as int,
      category: json['category'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'amount': amount,
      'date': date.toIso8601String().split('T').first,
      'description': description,
    };
  }
}
