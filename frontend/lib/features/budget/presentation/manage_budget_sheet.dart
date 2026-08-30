import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../budget_model.dart';
import '../budget_provider.dart';
import 'create_budget_sheet.dart';
import 'edit_budget_sheet.dart';

class ManageBudgetSheet extends ConsumerWidget {
  const ManageBudgetSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetState = ref.watch(budgetProvider);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          16,
          24,
          24 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: budgetState.when(
          loading: () => const SizedBox(
            height: 220,
            child: Center(child: CircularProgressIndicator()),
          ),

          error: (error, stackTrace) => _ErrorView(
            onRetry: () {
              ref.read(budgetProvider.notifier).refresh();
            },
          ),

          data: (budgets) {
            final now = DateTime.now();

            final currentBudgets = budgets
                .where(
                  (budget) =>
                      budget.month == now.month && budget.year == now.year,
                )
                .toList();

            if (currentBudgets.isEmpty) {
              return _NoBudgetView(monthName: _monthName(now.month));
            }

            return _BudgetView(budget: currentBudgets.first);
          },
        ),
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return months[month - 1];
  }
}

// ============================================================
// NO BUDGET
// ============================================================

class _NoBudgetView extends StatelessWidget {
  final String monthName;

  const _NoBudgetView({required this.monthName});

  Future<void> _createBudget(BuildContext context) async {
    Navigator.pop(context);

    await Future.delayed(const Duration(milliseconds: 150));

    if (!context.mounted) return;

    await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (_) {
        return const CreateBudgetSheet();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DragHandle(),

        const SizedBox(height: 24),

        const Text(
          'Manage Budget',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 8),

        Text(
          'No budget has been created for $monthName yet.',
          style: TextStyle(color: Colors.grey.shade600),
        ),

        const SizedBox(height: 20),

        // STATUS CARD
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Budget not set',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      'Set a limit to track your monthly spending.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // CREATE
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => _createBudget(context),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            icon: const Icon(Icons.add),
            label: Text(
              'Create $monthName Budget',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // DELETE
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('There is no budget to delete.')),
              );
            },
            icon: const Icon(Icons.delete_outline),
            label: const Text('Delete Budget'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey.shade500,
              side: BorderSide(color: Colors.grey.shade300),
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// BUDGET EXISTS
// ============================================================

class _BudgetView extends ConsumerWidget {
  final BudgetModel budget;

  const _BudgetView({required this.budget});

  // ----------------------------------------------------------
  // EDIT
  // ----------------------------------------------------------

  Future<void> _editBudget(BuildContext context) async {
    Navigator.pop(context);

    await Future.delayed(const Duration(milliseconds: 150));

    if (!context.mounted) return;

    await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (_) {
        return EditBudgetSheet(budget: budget);
      },
    );
  }

  // ----------------------------------------------------------
  // DELETE
  // ----------------------------------------------------------

  Future<void> _deleteBudget(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Budget?'),

          content: const Text(
            'This will remove your current monthly budget. '
            'Your transactions will not be deleted.',
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),

            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    try {
      await ref.read(budgetProvider.notifier).deleteBudget(budget.id);

      if (!context.mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Budget deleted successfully.')),
      );
    } catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete budget: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DragHandle(),

        const SizedBox(height: 24),

        const Text(
          'Manage Budget',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 8),

        Text(
          'Your current monthly spending limit.',
          style: TextStyle(color: Colors.grey.shade600),
        ),

        const SizedBox(height: 20),

        // BUDGET CARD
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.account_balance_wallet_outlined,
                    color: AppColors.primary,
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    child: Text(
                      budget.category,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              Text(
                '₹${budget.amount.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                'Monthly spending limit',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // EDIT
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _editBudget(context),
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Edit Budget'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // DELETE
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _deleteBudget(context, ref),
            icon: const Icon(Icons.delete_outline),
            label: const Text('Delete Budget'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: BorderSide(color: Colors.red.shade300),
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// DRAG HANDLE
// ============================================================

class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}

// ============================================================
// ERROR
// ============================================================

class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 40, color: Colors.grey.shade500),

          const SizedBox(height: 12),

          Text(
            'Unable to load budget.',
            style: TextStyle(color: Colors.grey.shade700),
          ),

          const SizedBox(height: 16),

          OutlinedButton(onPressed: onRetry, child: const Text('Try Again')),
        ],
      ),
    );
  }
}
