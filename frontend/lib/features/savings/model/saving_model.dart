class SavingModel {
  final int id;
  final int? goalId;
  final double amount;
  final DateTime date;
  final String? description;

  const SavingModel({
    required this.id,
    required this.goalId,
    required this.amount,
    required this.date,
    this.description,
  });

  factory SavingModel.fromJson(Map<String, dynamic> json) {
    return SavingModel(
      id: (json['id'] as num).toInt(),
      goalId: json['goal_id'] == null ? null : (json['goal_id'] as num).toInt(),
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date']),
      description: json['description'],
    );
  }
}
