import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

class TransactionFilterChips extends StatefulWidget {
  const TransactionFilterChips({super.key});

  @override
  State<TransactionFilterChips> createState() => _TransactionFilterChipsState();
}

class _TransactionFilterChipsState extends State<TransactionFilterChips> {
  int selected = 0;

  final filters = ["All", "Income", "Expense", "Investments"];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (_, index) {
          final active = selected == index;

          return GestureDetector(
            onTap: () {
              setState(() => selected = index);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                color: active ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: AppColors.border),
              ),
              alignment: Alignment.center,
              child: Text(
                filters[index],
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w600,
                  color: active ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
