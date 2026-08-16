import 'package:flutter/material.dart';
import 'package:youthfinance/features/transactions/model/transaction_filter.dart';
import 'package:youthfinance/features/transactions/presentation/widgets/add_transaction_sheet.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../design_system/layout/app_scaffold.dart';
import '../widgets/filter_chips.dart';
import '../widgets/monthly_summary.dart';
import '../widgets/transaction_list.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  TransactionFilter selectedFilter = TransactionFilter.all;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () async {
          final result = await showModalBottomSheet<String>(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.white,
            builder: (context) {
              return const AddTransactionSheet();
            },
          );

          if (!context.mounted) return;

          if (result == 'income') {
            // Income form will be connected in the next step.
            debugPrint('Income selected');
          }

          if (result == 'expense') {
            // Expense form will be connected after income.
            debugPrint('Expense selected');
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.sm),

            Text(
              "Transactions",
              style: AppTextStyles.heading.copyWith(fontSize: 28),
            ),

            const SizedBox(height: AppSpacing.xl),

            const MonthlySummary(),

            const SizedBox(height: 24),

            TransactionFilterChips(
              selected: selectedFilter,
              onSelected: (filter) {
                setState(() {
                  selectedFilter = filter;
                });
              },
            ),

            const SizedBox(height: 24),

            TransactionList(filter: selectedFilter),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
