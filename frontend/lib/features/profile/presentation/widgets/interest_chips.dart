import 'package:flutter/material.dart';

class InterestChips extends StatelessWidget {
  const InterestChips({super.key});

  @override
  Widget build(BuildContext context) {
    final chips = ["Budgeting", "Saving", "Investing", "Credit", "Taxes"];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: chips.map((chip) {
        return Chip(label: Text(chip));
      }).toList(),
    );
  }
}
