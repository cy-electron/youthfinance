class FunFundModel {
  final int id;
  final int budgetId;
  final String title;
  final double targetAmount;
  final double currentAmount;
  final DateTime? targetDate;
  final String status;
  final String? notes;

  const FunFundModel({
    required this.id,
    required this.budgetId,
    required this.title,
    required this.targetAmount,
    required this.currentAmount,
    this.targetDate,
    required this.status,
    this.notes,
  });

  factory FunFundModel.fromJson(Map<String, dynamic> json) {
    return FunFundModel(
      id: (json['id'] as num).toInt(),
      budgetId: (json['budget_id'] as num).toInt(),
      title: json['title'] as String,
      targetAmount: (json['target_amount'] as num).toDouble(),
      currentAmount: (json['current_amount'] as num).toDouble(),
      targetDate: json['target_date'] != null
          ? DateTime.parse(json['target_date'] as String)
          : null,
      status: json['status'] as String? ?? 'Active',
      notes: json['notes'] as String?,
    );
  }

  double get progress {
    if (targetAmount <= 0) return 0;

    return (currentAmount / targetAmount).clamp(0.0, 1.0);
  }

  double get remainingAmount {
    return (targetAmount - currentAmount).clamp(0.0, double.infinity);
  }

  bool get isCompleted {
    return currentAmount >= targetAmount;
  }
}