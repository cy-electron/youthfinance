import 'package:flutter/material.dart';

enum GoalStatus { onTrack, attention, delayed, completed }

class GoalModel {
  final String title;
  final String category;
  final double progress;

  final int saved;

  final int target;

  final int monthsLeft;

  final GoalStatus status;

  final String insight;

  final IconData icon;

  // Added: GoalCard's build() reads these, but they weren't on the
  // model yet. Adjust the type (int vs double) if your real data needs
  // decimals for monthlyContribution.
  final int monthlyContribution;
  final String expectedFinish;

  GoalModel({
    required this.title,
    required this.category,
    required this.progress,
    required this.saved,
    required this.target,
    required this.monthsLeft,
    required this.status,
    required this.insight,
    required this.icon,
    required this.monthlyContribution,
    required this.expectedFinish,
  });
}
