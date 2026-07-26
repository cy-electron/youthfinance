import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../design_system/layout/app_scaffold.dart';
import '../widgets/filter_chips.dart';
import '../widgets/monthly_summary.dart';
import '../widgets/transaction_list.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: "Transactions",

      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {},
        child: const Icon(Icons.add, color: Colors.white),
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            MonthlySummary(),

            SizedBox(height: 24),

            TransactionFilterChips(),

            SizedBox(height: 24),

            TransactionList(),

            SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
