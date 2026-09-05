import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../budget/budget_model.dart';
import '../../../budget/budget_provider.dart';
import '../../model/fun_fund_provider.dart';

class CreateFunFundSheet extends ConsumerStatefulWidget {
  const CreateFunFundSheet({super.key});

  @override
  ConsumerState<CreateFunFundSheet> createState() =>
      _CreateFunFundSheetState();
}

class _CreateFunFundSheetState
    extends ConsumerState<CreateFunFundSheet> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  BudgetModel? _selectedBudget;
  DateTime? _targetDate;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: DateTime(now.year + 10),
      initialDate: _targetDate ?? now,
    );

    if (picked != null) {
      setState(() {
        _targetDate = picked;
      });
    }
  }

  Future<void> _createFunFund() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedBudget == null) {
      _showMessage('Please select a budget.');
      return;
    }

    final amount = double.tryParse(
      _amountController.text.trim(),
    );

    if (amount == null || amount <= 0) {
      _showMessage('Please enter a valid amount.');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await ref.read(funFundProvider.notifier).addFunFund(
            budgetId: _selectedBudget!.id,
            title: _titleController.text.trim(),
            targetAmount: amount,
            targetDate: _targetDate,
            notes: _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
          );

      if (!mounted) return;

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fun Fund created successfully.'),
        ),
      );
    } catch (error) {
    if (!mounted) return;

    setState(() {
        _isSubmitting = false;
    });

    String message = 'Unable to create Fun Fund.';

    if (error is DioException) {
        final responseData = error.response?.data;

        if (responseData is Map<String, dynamic>) {
        final backendMessage = responseData['message'];

        if (backendMessage is String &&
            backendMessage.trim().isNotEmpty) {
            message = backendMessage;
        }
        }
    }

    _showMessage(message);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final budgetsAsync = ref.watch(budgetProvider);

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Create Fun Fund',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  IconButton(
                    onPressed: _isSubmitting
                        ? null
                        : () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Fun Fund name',
                  hintText: 'e.g. Weekend Trip',
                ),
                textCapitalization: TextCapitalization.sentences,
                validator: (value) {
                  if (value == null ||
                      value.trim().length < 2) {
                    return 'Enter at least 2 characters.';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              budgetsAsync.when(
                loading: () => const LinearProgressIndicator(),
                error: (error, stackTrace) => Text(
                  'Unable to load budgets: $error',
                ),
                data: (budgets) {
                    final now = DateTime.now();

                    final currentMonthBudgets = budgets.where((budget) {
                        return budget.month == now.month &&
                            budget.year == now.year;
                    }).toList();

                    if (currentMonthBudgets.isEmpty) {
                        return const Text(
                        'Create a budget for the current month before creating a Fun Fund.',
                        );
                    }

                    if (_selectedBudget != null &&
                        !currentMonthBudgets.any(
                            (budget) => budget.id == _selectedBudget!.id,
                        )) {
                        _selectedBudget = null;
                    }

                    return DropdownButtonFormField<BudgetModel>(
                        initialValue: _selectedBudget,
                        decoration: const InputDecoration(
                        labelText: 'Parent Budget',
                        ),
                        items: currentMonthBudgets.map((budget) {
                        return DropdownMenuItem<BudgetModel>(
                            value: budget,
                            child: Text(
                            '${budget.category} • '
                            '₹${budget.amount.toStringAsFixed(2)}',
                            ),
                        );
                        }).toList(),
                        onChanged: _isSubmitting
                            ? null
                            : (budget) {
                                setState(() {
                                _selectedBudget = budget;
                                });
                            },
                        validator: (value) {
                        if (value == null) {
                            return 'Select a budget.';
                        }

                        return null;
                        },
                    );
                    },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixText: '₹ ',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  final amount = double.tryParse(
                    value?.trim() ?? '',
                  );

                  if (amount == null || amount <= 0) {
                    return 'Enter a valid amount.';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              InkWell(
                onTap: _isSubmitting ? null : _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Target date',
                  ),
                  child: Text(
                    _targetDate == null
                        ? 'Optional'
                        : '${_targetDate!.day.toString().padLeft(2, '0')}/'
                          '${_targetDate!.month.toString().padLeft(2, '0')}/'
                          '${_targetDate!.year}',
                  ),
                ),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  hintText: 'Optional',
                ),
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isSubmitting
                      ? null
                      : _createFunFund,
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Create Fun Fund'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}