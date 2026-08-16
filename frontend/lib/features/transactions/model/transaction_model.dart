enum TransactionType { income, expense }

class TransactionModel {
  final int id;
  final TransactionType type;
  final String title;
  final String? description;
  final double amount;
  final DateTime date;

  const TransactionModel({
    required this.id,
    required this.type,
    required this.title,
    required this.amount,
    required this.date,
    this.description,
  });

  bool get isIncome => type == TransactionType.income;

  String get category => type == TransactionType.income ? 'Income' : title;
}
