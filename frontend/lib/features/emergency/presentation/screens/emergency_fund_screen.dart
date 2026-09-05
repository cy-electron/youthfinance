import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../design_system/cards/app_card.dart';
import '../../model/emergency_fund_provider.dart';

class EmergencyFundScreen extends ConsumerWidget {
  const EmergencyFundScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balance = ref.watch(emergencyFundProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Emergency Fund')),
      body: RefreshIndicator(
        onRefresh: () => ref.read(emergencyFundProvider.notifier).refresh(),
        child: balance.when(
          loading: () => const _LoadingView(),
          error: (error, _) => _ErrorView(
            onRetry: () => ref.read(emergencyFundProvider.notifier).refresh(),
          ),
          data: (amount) => ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              AppCard(
                color: AppColors.primaryDark,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Available for emergencies',
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      '₹${amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const Text(
                      'This is controlled money reserved from your general balance.',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text('Manage fund', style: AppTextStyles.sectionTitle),
              const SizedBox(height: AppSpacing.sm),
              FilledButton.icon(
                onPressed: () => _showMovementSheet(context, ref, isAdding: true),
                icon: const Icon(Icons.add),
                label: const Text('Add money from General'),
              ),
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton.icon(
                onPressed: amount == 0
                    ? null
                    : () => _showMovementSheet(context, ref, isAdding: false),
                icon: const Icon(Icons.keyboard_return_rounded),
                label: const Text('Release money to General'),
              ),
              const SizedBox(height: AppSpacing.xl),
              AppCard(
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('How it works', style: AppTextStyles.cardTitle),
                    SizedBox(height: AppSpacing.sm),
                    Text(
                      'Adding or releasing money moves it between your General and Emergency Fund buckets. It does not create income or an expense.',
                      style: AppTextStyles.body,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showMovementSheet(
    BuildContext context,
    WidgetRef ref, {
    required bool isAdding,
  }) async {
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    var isSubmitting = false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            MediaQuery.viewInsetsOf(context).bottom + AppSpacing.lg,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAdding ? 'Add to Emergency Fund' : 'Release to General',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  isAdding
                      ? 'Move available General money into your Emergency Fund.'
                      : 'Move Emergency Fund money back to your General balance.',
                ),
                const SizedBox(height: AppSpacing.lg),
                TextFormField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    prefixText: '₹ ',
                  ),
                  validator: (value) {
                    final amount = double.tryParse(value?.trim() ?? '');
                    return amount == null || amount <= 0
                        ? 'Enter an amount greater than zero.'
                        : null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: descriptionController,
                  maxLength: 500,
                  decoration: const InputDecoration(
                    labelText: 'Note (optional)',
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: isSubmitting
                        ? null
                        : () async {
                            if (!formKey.currentState!.validate()) return;
                            setState(() => isSubmitting = true);
                            try {
                              final amount = double.parse(amountController.text.trim());
                              if (isAdding) {
                                await ref.read(emergencyFundProvider.notifier).addMoney(
                                      amount: amount,
                                      description: descriptionController.text,
                                    );
                              } else {
                                await ref.read(emergencyFundProvider.notifier).releaseMoney(
                                      amount: amount,
                                      description: descriptionController.text,
                                    );
                              }
                              if (!context.mounted) return;
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    isAdding
                                        ? 'Emergency Fund updated.'
                                        : 'Money released to General.',
                                  ),
                                ),
                              );
                            } catch (_) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Unable to update the Emergency Fund.'),
                                ),
                              );
                            } finally {
                              if (context.mounted) setState(() => isSubmitting = false);
                            }
                          },
                    child: isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(isAdding ? 'Add money' : 'Release money'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    amountController.dispose();
    descriptionController.dispose();
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [SizedBox(height: 300, child: Center(child: CircularProgressIndicator()))],
    );
  }
}

class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        const SizedBox(height: 120),
        const Icon(Icons.error_outline, size: 48),
        const SizedBox(height: AppSpacing.md),
        const Center(child: Text('Unable to load your Emergency Fund.')),
        const SizedBox(height: AppSpacing.md),
        Center(child: FilledButton(onPressed: onRetry, child: const Text('Try again'))),
      ],
    );
  }
}
