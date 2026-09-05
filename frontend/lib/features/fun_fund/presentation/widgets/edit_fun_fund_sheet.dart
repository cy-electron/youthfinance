import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../model/fun_fund_model.dart';
import '../../model/fun_fund_provider.dart';

class EditFunFundSheet extends ConsumerStatefulWidget {
  final FunFundModel fund;

  const EditFunFundSheet({
    super.key,
    required this.fund,
  });

  @override
  ConsumerState<EditFunFundSheet> createState() =>
      _EditFunFundSheetState();
}

class _EditFunFundSheetState
    extends ConsumerState<EditFunFundSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late final TextEditingController _notesController;

  DateTime? _targetDate;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(
      text: widget.fund.title,
    );

    _amountController = TextEditingController(
      text: widget.fund.targetAmount.toStringAsFixed(2),
    );

    _notesController = TextEditingController(
      text: widget.fund.notes ?? '',
    );

    _targetDate = widget.fund.targetDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime? date) {
    if (date == null) {
      return 'Optional';
    }

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
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

  Future<void> _updateFunFund() async {
    if (!_formKey.currentState!.validate()) {
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
      await ref.read(funFundProvider.notifier).updateFunFund(
            widget.fund.id,
            title: _titleController.text.trim(),
            targetAmount: amount,
            targetDate: _targetDate,
            notes: _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
          );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fun Fund updated successfully.'),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSubmitting = false;
      });

      _showMessage(_getErrorMessage(error));
    }
  }

  String _getErrorMessage(Object error) {
    if (error is DioException) {
      final responseData = error.response?.data;

      if (responseData is Map<String, dynamic>) {
        final backendMessage = responseData['message'];

        if (backendMessage is String &&
            backendMessage.trim().isNotEmpty) {
          return backendMessage;
        }
      }
    }

    return 'Unable to update Fun Fund.';
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
                      'Edit Fun Fund',
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
                enabled: !_isSubmitting,
                decoration: const InputDecoration(
                  labelText: 'Fun Fund name',
                  hintText: 'e.g. Weekend Trip',
                ),
                textCapitalization:
                    TextCapitalization.sentences,
                validator: (value) {
                  if (value == null ||
                      value.trim().length < 2) {
                    return 'Enter at least 2 characters.';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _amountController,
                enabled: !_isSubmitting,
                decoration: const InputDecoration(
                  labelText: 'Target amount',
                  prefixText: '₹ ',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(
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
                    _formatDate(_targetDate),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _notesController,
                enabled: !_isSubmitting,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  hintText: 'Optional',
                ),
                maxLines: 3,
                textCapitalization:
                    TextCapitalization.sentences,
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed:
                      _isSubmitting ? null : _updateFunFund,
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Save changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}