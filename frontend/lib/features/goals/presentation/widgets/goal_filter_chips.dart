import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

enum GoalFilter { all, active, completed }

class GoalFilterChips extends StatelessWidget {
  final GoalFilter selectedFilter;
  final ValueChanged<GoalFilter> onFilterChanged;

  const GoalFilterChips({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  static const List<GoalFilter> filters = [
    GoalFilter.all,
    GoalFilter.active,
    GoalFilter.completed,
  ];

  String _label(GoalFilter filter) {
    switch (filter) {
      case GoalFilter.all:
        return 'All Goals';

      case GoalFilter.active:
        return 'Active';

      case GoalFilter.completed:
        return 'Completed';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: filters.length,
        separatorBuilder: (_, __) {
          return const SizedBox(width: AppSpacing.sm);
        },
        itemBuilder: (context, index) {
          final filter = filters[index];
          final selected = filter == selectedFilter;

          return ChoiceChip(
            label: Text(
              _label(filter),
              style: AppTextStyles.sectionTitle.copyWith(
                color: selected ? Colors.white : AppColors.textPrimary,
                fontSize: 15,
              ),
            ),

            selected: selected,

            onSelected: (_) {
              onFilterChanged(filter);
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

            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,

            visualDensity: VisualDensity.compact,

            labelPadding: EdgeInsets.zero,

            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          );
        },
      ),
    );
  }
}
