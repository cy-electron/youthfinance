import 'package:flutter/material.dart';
import 'package:youthfinance/features/transactions/presentation/widgets/add_expense_sheet.dart';
import 'package:youthfinance/features/transactions/presentation/widgets/add_income_sheet.dart';

class AddTransactionSheet extends StatelessWidget {
  const AddTransactionSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Add Transaction',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              'What would you like to add?',
              style: TextStyle(color: Colors.grey.shade600),
            ),

            const SizedBox(height: 24),

            _TransactionOption(
              icon: Icons.arrow_downward_rounded,
              title: 'Income',
              subtitle: 'Money coming in',
              iconColor: Colors.green,
              onTap: () {
                Navigator.pop(context);

                showModalBottomSheet<bool>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.white,
                  builder: (context) {
                    return const AddIncomeSheet();
                  },
                );
              },
            ),

            const SizedBox(height: 12),

            _TransactionOption(
              icon: Icons.arrow_upward_rounded,
              title: 'Expense',
              subtitle: 'Money going out',
              iconColor: Colors.red,
              onTap: () {
                Navigator.pop(context);

                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.white,
                  builder: (_) => const AddExpenseSheet(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final VoidCallback onTap;

  const _TransactionOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: iconColor.withValues(alpha: 0.1),
              child: Icon(icon, color: iconColor),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),

            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
