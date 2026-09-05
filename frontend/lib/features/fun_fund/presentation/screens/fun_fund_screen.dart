import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../../model/fun_fund_model.dart';
import '../../model/fun_fund_provider.dart';
import '../widgets/create_fun_fund_sheet.dart';
import '../widgets/fun_fund_card.dart';
import '../widgets/edit_fun_fund_sheet.dart';

class FunFundScreen extends ConsumerWidget {
  const FunFundScreen({super.key});

  void _openCreateSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const CreateFunFundSheet(),
    );
  }

  void _openEditSheet(
    BuildContext context,
    FunFundModel fund,
    ) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (_) => EditFunFundSheet(
        fund: fund,
        ),
    );
    }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final funFundsAsync = ref.watch(funFundProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fun Fund'),
      ),
      body: RefreshIndicator(
        onRefresh: () {
          return ref.read(funFundProvider.notifier).refresh();
        },
        child: funFundsAsync.when(
          loading: () => ListView(
            children: const [
              SizedBox(
                height: 300,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ],
          ),
          error: (error, stackTrace) => ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const SizedBox(height: 120),
              const Icon(
                Icons.error_outline,
                size: 48,
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  'Unable to load Fun Funds.',
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: FilledButton(
                  onPressed: () {
                    ref.invalidate(funFundProvider);
                  },
                  child: const Text('Try again'),
                ),
              ),
            ],
          ),
          data: (funds) {
            if (funds.isEmpty) {
              return ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  const SizedBox(height: 100),
                  Icon(
                    Icons.celebration_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'No Fun Funds yet',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Create a Fun Fund from one of your budgets '
                    'to set aside money for something you enjoy.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: FilledButton.icon(
                      onPressed: () => _openCreateSheet(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Create Fun Fund'),
                    ),
                  ),
                ],
              );
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(
                16,
                16,
                16,
                100,
              ),
              children: [
                _buildSummary(context, funds),
                const SizedBox(height: 20),
                ...funds.map(
                  (fund) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: FunFundCard(
                      fund: fund,
                      onEdit: () {
                        _openEditSheet(context, fund);
                      },
                      onDelete: () {
                        _showDeleteOptions(
                          context,
                          ref,
                          fund,
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCreateSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('Create'),
      ),
    );
  }

  // ============================================================
  // DELETE OPTIONS
  // ============================================================

  Future<void> _showDeleteOptions(
    BuildContext context,
    WidgetRef ref,
    FunFundModel fund,
  ) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);

        return Padding(
          padding: const EdgeInsets.fromLTRB(
            20,
            12,
            20,
            24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Delete Fun Fund?',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                fund.title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color
                      ?.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 20),

              // --------------------------------------------------
              // FINISH
              // --------------------------------------------------

              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor:
                      theme.colorScheme.primaryContainer,
                  child: Icon(
                    Icons.check_circle_outline,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                title: const Text(
                  'Finish Fun Fund',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  'Record ₹${fund.currentAmount.toStringAsFixed(2)} '
                  'as an expense.',
                ),
                onTap: () {
                  Navigator.pop(
                    sheetContext,
                    'finish',
                  );
                },
              ),

              const SizedBox(height: 8),

              // --------------------------------------------------
              // CANCEL
              // --------------------------------------------------

              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor:
                      theme.colorScheme.surfaceContainerHighest,
                  child: Icon(
                    Icons.undo_outlined,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                title: const Text(
                  'Cancel plan',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: const Text(
                  'Return the remaining money to your budget.',
                ),
                onTap: () {
                  Navigator.pop(
                    sheetContext,
                    'cancel',
                  );
                },
              ),

              const SizedBox(height: 8),

              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                  },
                  child: const Text('Keep Fun Fund'),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (!context.mounted || action == null) {
      return;
    }

    if (action == 'cancel') {
      await _cancelFunFund(
        context,
        ref,
        fund,
      );
    }

    if (action == 'finish') {
      await _finishFunFund(
        context,
        fund,
      );
    }
  }

  // ============================================================
  // CANCEL PLAN
  // ============================================================

  Future<void> _cancelFunFund(
    BuildContext context,
    WidgetRef ref,
    FunFundModel fund,
  ) async {
    try {
      await ref
          .read(funFundProvider.notifier)
          .deleteFunFund(fund.id);

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Fun Fund cancelled. The remaining money was returned to your budget.',
          ),
        ),
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _extractErrorMessage(error),
          ),
        ),
      );
    }
  }

  // ============================================================
  // FINISH FUN FUND
  // ============================================================

  Future<void> _finishFunFund(
    BuildContext context,
    FunFundModel fund,
  ) async {
    if (fund.currentAmount <= 0) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'This Fun Fund has no remaining money to finish.',
          ),
        ),
      );

      return;
    }

    if (!context.mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Finish Fun Fund'),
          content: Text(
            '₹${fund.currentAmount.toStringAsFixed(2)} '
            'will be recorded as an expense for '
            '"${fund.title}".\n\n'
            'This means the money will leave your wallet.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                _showFinishExpenseMessage(
                  context,
                  fund,
                );
              },
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showFinishExpenseMessage(
    BuildContext context,
    FunFundModel fund,
  ) async {
    if (!context.mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add Expense'),
          content: Text(
            'Add ₹${fund.currentAmount.toStringAsFixed(2)} '
            'as an expense to finish this Fun Fund.',
          ),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Open Add Expense to record the Fun Fund spending.',
                    ),
                  ),
                );
              },
              child: const Text('Add Expense'),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  String _extractErrorMessage(Object error) {
    if (error is DioException) {
      final responseData = error.response?.data;

      if (responseData is Map<String, dynamic>) {
        final message = responseData['message'];

        if (message is String && message.isNotEmpty) {
          return message;
        }
      }
    }

    return error.toString();
  }

  // ============================================================
  // SUMMARY
  // ============================================================

  Widget _buildSummary(
    BuildContext context,
    List<FunFundModel> funds,
  ) {
    final totalTarget = funds.fold<double>(
      0,
      (sum, fund) => sum + fund.targetAmount,
    );

    final totalSaved = funds.fold<double>(
      0,
      (sum, fund) => sum + fund.currentAmount,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Fun Funds',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _summaryValue(
                    context,
                    'Allocated',
                    totalSaved,
                  ),
                ),
                Expanded(
                  child: _summaryValue(
                    context,
                    'Targets',
                    totalTarget,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryValue(
    BuildContext context,
    String label,
    double amount,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 4),
        Text(
          '₹${amount.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}