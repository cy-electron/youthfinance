class InvestmentModel {
  final int id;
  final String type;
  final String name;
  final double amount;
  final double? currentValue;
  final DateTime investmentDate;
  final String? notes;

  const InvestmentModel({
    required this.id,
    required this.type,
    required this.name,
    required this.amount,
    this.currentValue,
    required this.investmentDate,
    this.notes,
  });

  factory InvestmentModel.fromJson(Map<String, dynamic> json) {
    return InvestmentModel(
      id: (json['id'] as num).toInt(),
      type: json['investment_type'] as String,
      name: json['investment_name'] as String,
      amount: (json['amount'] as num).toDouble(),
      currentValue: json['current_value'] == null
          ? null
          : (json['current_value'] as num).toDouble(),
      investmentDate: DateTime.parse(json['investment_date'] as String),
      notes: json['notes'] as String?,
    );
  }
}
