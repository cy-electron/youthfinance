class IncomeModel {
  final int id;
  final String source;
  final double amount;
  final DateTime date;
  final String? description;

  const IncomeModel({
    required this.id,
    required this.source,
    required this.amount,
    required this.date,
    this.description,
  });

  factory IncomeModel.fromJson(Map<String, dynamic> json) {
    return IncomeModel(
      id: json['id'] as int,
      source: json['source'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'source': source,
      'amount': amount,
      'date': date.toIso8601String().split('T').first,
      'description': description,
    };
  }
}
