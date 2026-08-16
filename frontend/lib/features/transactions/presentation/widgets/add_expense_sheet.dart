import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../expense/expense_provider.dart';

class AddExpenseSheet extends ConsumerStatefulWidget {
  const AddExpenseSheet({super.key});

  @override
  ConsumerState<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends ConsumerState<AddExpenseSheet> {
  final _formKey = GlobalKey<FormState>();

  final _categoryController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;

  @override
  void dispose() {
    _categoryController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final amount = double.tryParse(_amountController.text.trim());

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount.')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await ref
          .read(expenseProvider.notifier)
          .addExpense(
            category: _categoryController.text.trim(),
            amount: amount,
            date: _selectedDate,
            description: _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
          );

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to add expense: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  'Add Expense',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 8),

                Text(
                  'Record money you spent.',
                  style: TextStyle(color: Colors.grey.shade600),
                ),

                const SizedBox(height: 24),

                // CATEGORY
                TextFormField(
                  controller: _categoryController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Expense Category',
                    hintText: 'e.g. Food, Transport, Shopping',
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter the expense category';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // AMOUNT
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    hintText: 'e.g. 850',
                    prefixText: '₹ ',
                    prefixIcon: Icon(Icons.currency_rupee),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter an amount';
                    }

                    final amount = double.tryParse(value.trim());

                    if (amount == null || amount <= 0) {
                      return 'Enter a valid positive amount';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // DATE
                InkWell(
                  onTap: _selectDate,
                  borderRadius: BorderRadius.circular(12),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Date',
                      prefixIcon: Icon(Icons.calendar_today_outlined),
                    ),
                    child: Text(
                      '${_selectedDate.day.toString().padLeft(2, '0')}/'
                      '${_selectedDate.month.toString().padLeft(2, '0')}/'
                      '${_selectedDate.year}',
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // DESCRIPTION
                TextFormField(
                  controller: _descriptionController,
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Optional',
                    prefixIcon: Icon(Icons.notes_outlined),
                  ),
                ),

                const SizedBox(height: 24),

                // SAVE BUTTON
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isSaving ? null : _saveExpense,
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
                            'Add Expense',
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
}
