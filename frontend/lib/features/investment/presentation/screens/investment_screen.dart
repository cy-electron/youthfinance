import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../design_system/cards/app_card.dart';
import '../../model/investment_model.dart';
import '../../model/investment_provider.dart';

class InvestmentScreen extends ConsumerWidget {
  const InvestmentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final investments = ref.watch(investmentProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Investments'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateSheet(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add investment'),
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(investmentProvider.notifier).refresh(),
        child: investments.when(
          loading: () => const _LoadingView(),
          error: (_, __) => _ErrorView(
            onRetry: () =>
                ref.read(investmentProvider.notifier).refresh(),
          ),
          data: (items) {
            if (items.isEmpty) {
              return _EmptyView(
                onCreate: () => _showCreateSheet(context, ref),
              );
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                100,
              ),
              children: [
                _Summary(items: items),
                const SizedBox(height: AppSpacing.lg),
                ...items.map(
                  (investment) => Padding(
                    padding: const EdgeInsets.only(
                      bottom: AppSpacing.sm,
                    ),
                    child: _InvestmentCard(
                      investment: investment,
                      onDelete: () => _confirmDelete(
                        context,
                        ref,
                        investment,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    InvestmentModel investment,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete investment record?'),
        content: Text(
          'Remove ${investment.name} from your recorded investments?',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete != true || !context.mounted) {
      return;
    }

    try {
      await ref
          .read(investmentProvider.notifier)
          .deleteInvestment(investment.id);

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Investment record deleted.'),
        ),
      );
    } catch (_) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to delete investment record.'),
        ),
      );
    }
  }

  Future<void> _showCreateSheet(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) {
        return _CreateInvestmentSheet(
          onSubmit: ({
            required String type,
            required String name,
            required double amount,
            double? currentValue,
            required DateTime date,
            String? notes,
          }) {
            return ref
                .read(investmentProvider.notifier)
                .addInvestment(
                  type: type,
                  name: name,
                  amount: amount,
                  currentValue: currentValue,
                  date: date,
                  notes: notes,
                );
          },
        );
      },
    );

    if (created == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Investment recorded.'),
        ),
      );
    }
  }
}

typedef InvestmentSubmitCallback = Future<void> Function({
  required String type,
  required String name,
  required double amount,
  double? currentValue,
  required DateTime date,
  String? notes,
});

class _CreateInvestmentSheet extends StatefulWidget {
  final InvestmentSubmitCallback onSubmit;

  const _CreateInvestmentSheet({
    required this.onSubmit,
  });

  @override
  State<_CreateInvestmentSheet> createState() =>
      _CreateInvestmentSheetState();
}

class _CreateInvestmentSheetState
    extends State<_CreateInvestmentSheet> {
  late final GlobalKey<FormState> _formKey;

  late final TextEditingController _nameController;
  late final TextEditingController _amountController;
  late final TextEditingController _currentValueController;
  late final TextEditingController _notesController;

  String _type = 'Mutual Fund';
  DateTime _date = DateTime.now();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();

    _formKey = GlobalKey<FormState>();

    _nameController = TextEditingController();
    _amountController = TextEditingController();
    _currentValueController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _currentValueController.dispose();
    _notesController.dispose();

    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting) {
      return;
    }

    final formState = _formKey.currentState;

    if (formState == null || !formState.validate()) {
      return;
    }

    final amount = double.tryParse(
      _amountController.text.trim(),
    );

    if (amount == null || amount <= 0) {
      return;
    }

    final currentValueText =
        _currentValueController.text.trim();

    final currentValue = currentValueText.isEmpty
        ? null
        : double.tryParse(currentValueText);

    if (currentValueText.isNotEmpty &&
        (currentValue == null || currentValue < 0)) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await widget.onSubmit(
        type: _type,
        name: _nameController.text.trim(),
        amount: amount,
        currentValue: currentValue,
        date: _date,
        notes: _notesController.text.trim(),
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSubmitting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to record investment.'),
        ),
      );
    }
  }

  Future<void> _selectDate() async {
    if (_isSubmitting) {
      return;
    }

    final selected = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (!mounted || selected == null) {
      return;
    }

    setState(() {
      _date = selected;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        bottomInset + AppSpacing.lg,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add investment',
                style: Theme.of(context).textTheme.titleLarge,
              ),

              const SizedBox(height: AppSpacing.lg),

              DropdownButtonFormField<String>(
                initialValue: _type,
                decoration: const InputDecoration(
                  labelText: 'Investment type',
                ),
                items: const [
                  'SIP',
                  'Mutual Fund',
                  'Fixed Deposit',
                  'Gold',
                  'Stocks',
                  'PPF',
                  'EPF',
                  'Crypto',
                  'Other',
                ]
                    .map(
                      (value) => DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      ),
                    )
                    .toList(),
                onChanged: _isSubmitting
                    ? null
                    : (value) {
                        if (value == null) {
                          return;
                        }

                        setState(() {
                          _type = value;
                        });
                      },
              ),

              const SizedBox(height: AppSpacing.md),

              TextFormField(
                controller: _nameController,
                enabled: !_isSubmitting,
                maxLength: 100,
                decoration: const InputDecoration(
                  labelText: 'Investment name',
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Enter an investment name.';
                  }

                  return null;
                },
              ),

              const SizedBox(height: AppSpacing.md),

              TextFormField(
                controller: _amountController,
                enabled: !_isSubmitting,
                keyboardType:
                    const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Amount invested',
                  prefixText: '₹ ',
                ),
                validator: _positiveAmount,
              ),

              const SizedBox(height: AppSpacing.md),

              TextFormField(
                controller: _currentValueController,
                enabled: !_isSubmitting,
                keyboardType:
                    const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Current value (optional)',
                  prefixText: '₹ ',
                ),
                validator: _nonNegativeAmount,
              ),

              const SizedBox(height: AppSpacing.md),

              ListTile(
                enabled: !_isSubmitting,
                contentPadding: EdgeInsets.zero,
                title: const Text('Investment date'),
                subtitle: Text(
                  '${_date.day}/${_date.month}/${_date.year}',
                ),
                trailing: const Icon(
                  Icons.calendar_today_outlined,
                ),
                onTap: _selectDate,
              ),

              TextFormField(
                controller: _notesController,
                enabled: !_isSubmitting,
                maxLength: 500,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Save investment'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String? _positiveAmount(String? value) {
    final amount = double.tryParse(
      value?.trim() ?? '',
    );

    if (amount == null || amount <= 0) {
      return 'Enter an amount greater than zero.';
    }

    return null;
  }

  static String? _nonNegativeAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final amount = double.tryParse(value.trim());

    if (amount == null || amount < 0) {
      return 'Enter zero or more.';
    }

    return null;
  }
}

class _Summary extends StatelessWidget {
  final List<InvestmentModel> items;

  const _Summary({
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final invested = items.fold<double>(
      0,
      (sum, item) => sum + item.amount,
    );

    final valued = items.fold<double>(
      0,
      (sum, item) =>
          sum + (item.currentValue ?? item.amount),
    );

    return AppCard(
      color: AppColors.primaryDark,
      child: Row(
        children: [
          Expanded(
            child: _Metric(
              label: 'Invested',
              value: invested,
            ),
          ),
          Expanded(
            child: _Metric(
              label: 'Current value',
              value: valued,
            ),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final double value;

  const _Metric({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '₹${value.toStringAsFixed(2)}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ],
    );
  }
}

class _InvestmentCard extends StatelessWidget {
  final InvestmentModel investment;
  final VoidCallback onDelete;

  const _InvestmentCard({
    required this.investment,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryLight,
          child: const Icon(
            Icons.trending_up_outlined,
            color: AppColors.primary,
          ),
        ),
        title: Text(
          investment.name,
          style: AppTextStyles.cardTitle,
        ),
        subtitle: Text(
          '${investment.type} • '
          '₹${investment.amount.toStringAsFixed(2)} invested',
        ),
        trailing: IconButton(
          tooltip: 'Delete investment record',
          icon: const Icon(Icons.delete_outline),
          onPressed: onDelete,
        ),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        SizedBox(
          height: 300,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorView({
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        const SizedBox(height: 120),
        const Icon(
          Icons.error_outline,
          size: 48,
        ),
        const SizedBox(height: AppSpacing.md),
        const Center(
          child: Text('Unable to load investments.'),
        ),
        const SizedBox(height: AppSpacing.md),
        Center(
          child: FilledButton(
            onPressed: onRetry,
            child: const Text('Try again'),
          ),
        ),
      ],
    );
  }
}

class _EmptyView extends StatelessWidget {
  final VoidCallback onCreate;

  const _EmptyView({
    required this.onCreate,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        const SizedBox(height: 100),
        Icon(
          Icons.trending_up_outlined,
          size: 64,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: AppSpacing.md),
        const Text(
          'No investments recorded',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        const Text(
          'Record investments you already hold to keep '
          'their details in one place.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.lg),
        Center(
          child: FilledButton.icon(
            onPressed: onCreate,
            icon: const Icon(Icons.add),
            label: const Text('Add investment'),
          ),
        ),
      ],
    );
  }
}