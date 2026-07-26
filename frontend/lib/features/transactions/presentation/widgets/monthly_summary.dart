import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../design_system/cards/app_card.dart';

class MonthlySummary extends StatelessWidget {
  const MonthlySummary({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Row(
        children: const [
          Expanded(
            child: _SummaryItem(title: "Income", value: "₹35,000"),
          ),

          Expanded(
            child: _SummaryItem(title: "Expense", value: "₹22,000"),
          ),

          Expanded(
            child: _SummaryItem(
              title: "Net Savings",
              value: "+₹13,000",
              isPositive: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String title;
  final String value;
  final bool isPositive;

  const _SummaryItem({
    required this.title,
    required this.value,
    this.isPositive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title.toUpperCase(),
          style: AppTextStyles.caption.copyWith(letterSpacing: 1),
        ),

        const SizedBox(height: AppSpacing.sm),

        Text(
          value,
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w700,
            color: isPositive ? AppColors.success : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
