import 'package:flutter/material.dart';
import 'package:youthfinance/features/transactions/model/transaction_filter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

class TransactionFilterChips extends StatelessWidget {
  final TransactionFilter selected;
  final ValueChanged<TransactionFilter> onSelected;

  const TransactionFilterChips({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  static const filters = [
    TransactionFilter.all,
    TransactionFilter.income,
    TransactionFilter.expense,
    TransactionFilter.investments,
  ];

  String _label(TransactionFilter filter) {
    switch (filter) {
      case TransactionFilter.all:
        return 'All';

      case TransactionFilter.income:
        return 'Income';

      case TransactionFilter.expense:
        return 'Expense';

      case TransactionFilter.investments:
        return 'Investments';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (_, index) {
          final filter = filters[index];
          final active = selected == filter;

          return GestureDetector(
            onTap: () => onSelected(filter),
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
                _label(filter),
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
