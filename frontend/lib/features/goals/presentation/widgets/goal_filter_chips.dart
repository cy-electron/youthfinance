import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

class GoalFilterChips extends StatefulWidget {
  const GoalFilterChips({super.key});

  @override
  State<GoalFilterChips> createState() => _GoalFilterChipsState();
}

class _GoalFilterChipsState extends State<GoalFilterChips> {
  int selectedIndex = 0;

  final filters = const [
    "All Goals",
    "Travel",
    "Tech",
    "Home",
    "Education",
    "Emergency",
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // Was 35 — too tight for the chip's own padding + Material's
      // default tap-target sizing, which pushed the label off-center.
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final selected = index == selectedIndex;

          return ChoiceChip(
            label: Text(
              filters[index],
              style: AppTextStyles.sectionTitle.copyWith(
                color: selected ? Colors.white : AppColors.textPrimary,
                fontSize: 15,
              ),
            ),

            selected: selected,

            onSelected: (_) {
              setState(() {
                selectedIndex = index;
              });
            },

            backgroundColor: Colors.white,

            selectedColor: AppColors.primary,

            side: BorderSide(
              color: selected ? AppColors.primary : Colors.grey.shade300,
            ),

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),

            showCheckmark: false,

            // Removes Material's default extra tap-target padding around
            // the chip, which was the other piece fighting the label for
            // vertical centering.
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
            labelPadding: EdgeInsets.zero,

            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          );
        },
      ),
    );
  }
}
