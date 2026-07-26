import 'package:flutter/material.dart';
import 'package:youthfinance/features/goals/model/goal_model.dart';

// NOTE: monthlyContribution and expectedFinish are placeholder values —
// please replace with real figures if you have them.
final dummyGoals = [
  GoalModel(
    title: "Japan Trip",
    category: "Travel",
    progress: .60,
    saved: 42000,
    target: 70000,
    monthsLeft: 4,
    status: GoalStatus.onTrack,
    insight: "You are ahead of schedule.",
    icon: Icons.flight,
    monthlyContribution: 7000,
    expectedFinish: "Nov 2026",
  ),

  GoalModel(
    title: "MacBook Pro",
    category: "Tech",
    progress: .32,
    saved: 32000,
    target: 100000,
    monthsLeft: 6,
    status: GoalStatus.attention,
    insight: "Increase contribution by ₹500/month.",
    icon: Icons.laptop_mac,
    monthlyContribution: 11000,
    expectedFinish: "Jan 2027",
  ),

  GoalModel(
    title: "Emergency Fund",
    category: "Emergency",
    progress: .15,
    saved: 15000,
    target: 100000,
    monthsLeft: 12,
    status: GoalStatus.delayed,
    insight: "You missed the last 2 contributions.",
    icon: Icons.health_and_safety,
    monthlyContribution: 7000,
    expectedFinish: "Jul 2027",
  ),
];
