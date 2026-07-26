import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

import '../../../../design_system/cards/summary_card.dart';
import '../../../../design_system/typography/section_header.dart';

class MonthlySnapshotSection extends StatelessWidget {
  const MonthlySnapshotSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: "Monthly Snapshot"),

        const SizedBox(height: AppSpacing.md),

        // ---- Single horizontal row of cards (scrollable on narrow screens) ----
        // No fixed height here: IntrinsicHeight lets the row size itself to
        // whatever the tallest SummaryCard actually needs, so text is never
        // clipped by a guessed pixel value (that's what caused the
        // "BOTTOM OVERFLOWED BY 1.00 PIXELS" errors).
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: const [
                SizedBox(
                  width: 160,
                  child: SummaryCard(
                    icon: Icons.account_balance_wallet_outlined,
                    iconColor: AppColors.primary,
                    title: "Income",
                    value: "₹65,000",
                    change: "+12%",
                    changeColor: AppColors.success,
                  ),
                ),

                SizedBox(width: AppSpacing.md),

                SizedBox(
                  width: 160,
                  child: SummaryCard(
                    icon: Icons.credit_card,
                    iconColor: AppColors.expense,
                    title: "Expenses",
                    value: "₹42,000",
                    change: "-5%",
                    changeColor: AppColors.expense,
                  ),
                ),

                SizedBox(width: AppSpacing.md),

                SizedBox(
                  width: 160,
                  child: SummaryCard(
                    icon: Icons.savings_outlined,
                    iconColor: AppColors.success,
                    title: "Savings",
                    value: "₹23,000",
                    change: "+18%",
                    changeColor: AppColors.success,
                  ),
                ),

                SizedBox(width: AppSpacing.md),

                SizedBox(
                  width: 160,
                  child: SummaryCard(
                    icon: Icons.account_balance_wallet,
                    iconColor: AppColors.primary,
                    title: "Budget Left",
                    value: "₹8,000",
                    showProgress: true,
                    progress: .65,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
