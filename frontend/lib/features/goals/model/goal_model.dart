import 'package:flutter/material.dart';

enum GoalStatus { onTrack, attention, delayed, completed }

class GoalModel {
  final int id;
  final String title;
  final double targetAmount;
  final double currentAmount;
  final DateTime targetDate;
  final String? description;
  final bool isCompleted;

  const GoalModel({
    required this.id,
    required this.title,
    required this.targetAmount,
    required this.currentAmount,
    required this.targetDate,
    this.description,
    this.isCompleted = false,
  });

  factory GoalModel.fromJson(Map<String, dynamic> json) {
    final targetAmount = (json['target_amount'] as num).toDouble();
    final currentAmount = (json['current_amount'] as num).toDouble();

    return GoalModel(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      targetAmount: targetAmount,
      currentAmount: currentAmount,
      targetDate: DateTime.parse(json['target_date'] as String),
      description: json['description'] as String?,
      isCompleted:
          json['is_completed'] as bool? ?? currentAmount >= targetAmount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'target_amount': targetAmount,
      'current_amount': currentAmount,
      'target_date': targetDate.toIso8601String().split('T').first,
      'description': description,
      'is_completed': isCompleted,
    };
  }

  // ------------------------------------------------------------
  // DERIVED VALUES
  // ------------------------------------------------------------

  double get progress {
    if (targetAmount <= 0) return 0;

    return (currentAmount / targetAmount).clamp(0.0, 1.0);
  }

  double get remainingAmount {
    return (targetAmount - currentAmount).clamp(0.0, double.infinity);
  }

  int get monthsLeft {
    final now = DateTime.now();

    if (targetDate.isBefore(now)) {
      return 0;
    }

    final months =
        (targetDate.year - now.year) * 12 + targetDate.month - now.month;

    return months < 1 ? 1 : months;
  }

  double get requiredMonthlyAmount {
    if (remainingAmount <= 0) return 0;

    final months = monthsLeft;

    if (months <= 0) {
      return remainingAmount;
    }

    return remainingAmount / months;
  }

  GoalStatus get status {
    if (isCompleted || currentAmount >= targetAmount) {
      return GoalStatus.completed;
    }

    if (targetDate.isBefore(DateTime.now())) {
      return GoalStatus.delayed;
    }

    return GoalStatus.onTrack;
  }

  String get statusText {
    switch (status) {
      case GoalStatus.onTrack:
        return 'ON TRACK';

      case GoalStatus.attention:
        return 'NEEDS ATTENTION';

      case GoalStatus.delayed:
        return 'DELAYED';

      case GoalStatus.completed:
        return 'COMPLETED';
    }
  }

  String get insight {
    switch (status) {
      case GoalStatus.completed:
        return 'You reached your goal.';

      case GoalStatus.delayed:
        return 'Your target date has passed.';

      case GoalStatus.attention:
        return 'Consider increasing your contribution.';

      case GoalStatus.onTrack:
        return 'Keep going, you are making progress.';
    }
  }

  IconData get icon {
    final text = title.toLowerCase();

    if (text.contains('travel') ||
        text.contains('trip') ||
        text.contains('vacation')) {
      return Icons.flight;
    }

    if (text.contains('laptop') ||
        text.contains('phone') ||
        text.contains('macbook') ||
        text.contains('computer')) {
      return Icons.laptop_mac;
    }

    if (text.contains('emergency')) {
      return Icons.health_and_safety;
    }

    if (text.contains('education') ||
        text.contains('course') ||
        text.contains('college')) {
      return Icons.school_outlined;
    }

    if (text.contains('home') || text.contains('house')) {
      return Icons.home_outlined;
    }

    return Icons.flag_outlined;
  }

  String get expectedFinish {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${months[targetDate.month - 1]} ${targetDate.year}';
  }
}
