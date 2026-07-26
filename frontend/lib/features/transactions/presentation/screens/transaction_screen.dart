import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../design_system/layout/app_scaffold.dart';
import '../widgets/filter_chips.dart';
import '../widgets/monthly_summary.dart';
import '../widgets/transaction_list.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      // Dropped AppScaffold's `title` (renders as a plain, small AppBar
      // title) in favor of a bold custom heading below, matching the
      // Goals/Insights screens' header style.
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {},
        child: const Icon(Icons.add, color: Colors.white),
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Small top breathing space before the bold title, same as
            // the fix applied to the Profile screen's header.
            const SizedBox(height: AppSpacing.sm),

            Text(
              "Transactions",
              style: AppTextStyles.heading.copyWith(fontSize: 28),
            ),

            const SizedBox(height: AppSpacing.xl),

            const MonthlySummary(),

            const SizedBox(height: 24),

            const TransactionFilterChips(),

            const SizedBox(height: 24),

            const TransactionList(),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
