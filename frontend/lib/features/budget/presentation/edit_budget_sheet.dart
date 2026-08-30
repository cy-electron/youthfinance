import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../budget_model.dart';
import '../budget_provider.dart';

class EditBudgetSheet extends ConsumerStatefulWidget {
  final BudgetModel budget;

  const EditBudgetSheet({super.key, required this.budget});

  @override
  ConsumerState<EditBudgetSheet> createState() => _EditBudgetSheetState();
}

class _EditBudgetSheetState extends ConsumerState<EditBudgetSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _categoryController;
  late final TextEditingController _amountController;

  late int _selectedMonth;
  late int _selectedYear;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _categoryController = TextEditingController(text: widget.budget.category);

    _amountController = TextEditingController(
      text: widget.budget.amount.toStringAsFixed(0),
    );

    _selectedMonth = widget.budget.month;
    _selectedYear = widget.budget.year;
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
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
          .updateBudget(
            widget.budget.id,
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
        SnackBar(content: Text('Failed to update budget: $error')),
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
                // --------------------------------------------------
                // DRAG HANDLE
                // --------------------------------------------------
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

                // --------------------------------------------------
                // HEADER
                // --------------------------------------------------
                const Text(
                  'Edit Budget',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 8),

                Text(
                  'Update your monthly spending limit.',
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
                  'You can edit the current or a future month budget.',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),

                const SizedBox(height: 24),

                // --------------------------------------------------
                // SAVE CHANGES
                // --------------------------------------------------
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isSaving ? null : _saveChanges,
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
                            'Save Changes',
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
