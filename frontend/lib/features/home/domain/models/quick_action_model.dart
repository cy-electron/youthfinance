import 'package:flutter/material.dart';

class QuickActionModel {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const QuickActionModel({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}
