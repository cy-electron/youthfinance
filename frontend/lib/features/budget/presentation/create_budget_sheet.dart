import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../budget_provider.dart';

class CreateBudgetSheet extends ConsumerStatefulWidget {
  const CreateBudgetSheet({super.key});

  @override
  ConsumerState<CreateBudgetSheet> createState() => _CreateBudgetSheetState();
}

class _CreateBudgetSheetState extends ConsumerState<CreateBudgetSheet> {
  final _formKey = GlobalKey<FormState>();

  final _categoryController = TextEditingController(text: 'Monthly Budget');

  final _amountController = TextEditingController();

  late int _selectedMonth;
  late int _selectedYear;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();

    _selectedMonth = now.month;
    _selectedYear = now.year;
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _createBudget() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final amount = double.tryParse(_amountController.text.trim());

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid budget amount.')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await ref
          .read(budgetProvider.notifier)
          .addBudget(
            category: _categoryController.text.trim(),
            amount: amount,
            month: _selectedMonth,
            year: _selectedYear,
          );

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create budget: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          16,
          24,
          24 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle
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
                  'Create Budget',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 8),

                Text(
                  'Set a spending limit for your monthly expenses.',
                  style: TextStyle(color: Colors.grey.shade600),
                ),

                const SizedBox(height: 24),

                // --------------------------------------------------
                // BUDGET LABEL
                // --------------------------------------------------
                TextFormField(
                  controller: _categoryController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Budget label',
                    hintText: 'e.g. Monthly Budget',
                    prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a budget label';
                    }

                    if (value.trim().length < 2) {
                      return 'Budget label is too short';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // --------------------------------------------------
                // AMOUNT
                // --------------------------------------------------
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Monthly budget',
                    hintText: 'e.g. 20000',
                    prefixText: '₹ ',
                    prefixIcon: Icon(Icons.currency_rupee),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a budget amount';
                    }

                    final amount = double.tryParse(value.trim());

                    if (amount == null) {
                      return 'Enter a valid amount';
                    }

                    if (amount <= 0) {
                      return 'Amount must be greater than 0';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // --------------------------------------------------
                // MONTH + YEAR
                // --------------------------------------------------
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        initialValue: _selectedMonth,
                        decoration: const InputDecoration(labelText: 'Month'),
                        items: List.generate(12, (index) {
                          final month = index + 1;

                          // Don't allow a past month in the current year.
                          final isPastMonth =
                              _selectedYear == now.year && month < now.month;

                          return DropdownMenuItem<int>(
                            value: month,
                            enabled: !isPastMonth,
                            child: Text(
                              _monthName(month),
                              style: TextStyle(
                                color: isPastMonth
                                    ? Colors.grey.shade400
                                    : null,
                              ),
                            ),
                          );
                        }),
                        onChanged: (value) {
                          if (value == null) return;

                          setState(() {
                            _selectedMonth = value;
                          });
                        },
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: DropdownButtonFormField<int>(
                        initialValue: _selectedYear,
                        decoration: const InputDecoration(labelText: 'Year'),
                        items: List.generate(3, (index) {
                          final year = now.year + index;

                          return DropdownMenuItem<int>(
                            value: year,
                            child: Text(year.toString()),
                          );
                        }),
                        onChanged: (value) {
                          if (value == null) return;

                          setState(() {
                            _selectedYear = value;

                            // If switching back to current year,
                            // don't leave a past month selected.
                            if (_selectedYear == now.year &&
                                _selectedMonth < now.month) {
                              _selectedMonth = now.month;
                            }
                          });
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                Text(
                  'You can create a budget for the current or a future month.',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),

                const SizedBox(height: 24),

                // --------------------------------------------------
                // SAVE
                // --------------------------------------------------
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isSaving ? null : _createBudget,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Create Budget',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                  ),
                ),
              ],
            ),
          ),
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
