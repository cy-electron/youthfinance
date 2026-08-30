import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youthfinance/features/goals/model/goal_provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

class CreateGoalSheet extends ConsumerStatefulWidget {
  const CreateGoalSheet({super.key});

  @override
  ConsumerState<CreateGoalSheet> createState() => _CreateGoalSheetState();
}

class _CreateGoalSheetState extends ConsumerState<CreateGoalSheet> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _targetAmountController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime? _targetDate;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _targetAmountController.dispose();
    _descriptionController.dispose();

    super.dispose();
  }

  // ============================================================
  // TARGET DATE
  // ============================================================

  Future<void> _selectTargetDate() async {
    final now = DateTime.now();

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _targetDate ?? now.add(const Duration(days: 30)),
      firstDate: now,
      lastDate: DateTime(now.year + 20),
    );

    if (pickedDate != null) {
      setState(() {
        _targetDate = pickedDate;
      });
    }
  }

  // ============================================================
  // CREATE GOAL
  // ============================================================

  Future<void> _createGoal() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_targetDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a target date.')),
      );
      return;
    }

    final targetAmount = double.tryParse(_targetAmountController.text.trim());

    if (targetAmount == null || targetAmount <= 0) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await ref
          .read(goalProvider.notifier)
          .addGoal(
            title: _titleController.text.trim(),
            targetAmount: targetAmount,
            targetDate: _targetDate!,
            description: _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
          );

      if (!mounted) return;

      Navigator.of(context).pop(true);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Goal created. You can now add money to it.'),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not create goal: $error')));
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.xl,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ==================================================
                // DRAG HANDLE
                // ==================================================
                Center(
                  child: Container(
                    width: 42,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // ==================================================
                // TITLE
                // ==================================================
                Text(
                  'Create Goal',
                  style: AppTextStyles.heading.copyWith(fontSize: 24),
                ),

                const SizedBox(height: AppSpacing.xs),

                Text(
                  'Set a target and start building towards it.',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // ==================================================
                // GOAL NAME
                // ==================================================
                _buildLabel('Goal Name'),

                const SizedBox(height: AppSpacing.xs),

                TextFormField(
                  controller: _titleController,
                  textCapitalization: TextCapitalization.sentences,
                  enabled: !_isLoading,
                  decoration: _inputDecoration(hintText: 'e.g. Japan Trip'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a goal name.';
                    }

                    if (value.trim().length < 2) {
                      return 'Goal name is too short.';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: AppSpacing.lg),

                // ==================================================
                // TARGET AMOUNT
                // ==================================================
                _buildLabel('Target Amount'),

                const SizedBox(height: AppSpacing.xs),

                TextFormField(
                  controller: _targetAmountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  enabled: !_isLoading,
                  decoration: _inputDecoration(
                    hintText: 'e.g. 100000',
                    prefixText: '₹ ',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a target amount.';
                    }

                    final amount = double.tryParse(value.trim());

                    if (amount == null || amount <= 0) {
                      return 'Enter a valid amount greater than ₹0.';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: AppSpacing.lg),

                // ==================================================
                // TARGET DATE
                // ==================================================
                _buildLabel('Target Date'),

                const SizedBox(height: AppSpacing.xs),

                InkWell(
                  onTap: _isLoading ? null : _selectTargetDate,
                  borderRadius: BorderRadius.circular(12),
                  child: InputDecorator(
                    decoration: _inputDecoration(
                      hintText: 'Select target date',
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),

                        const SizedBox(width: AppSpacing.sm),

                        Text(
                          _targetDate == null
                              ? 'Select target date'
                              : _formatDate(_targetDate!),
                          style: AppTextStyles.body.copyWith(
                            color: _targetDate == null
                                ? AppColors.textSecondary
                                : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // ==================================================
                // DESCRIPTION
                // ==================================================
                _buildLabel('Description'),

                const SizedBox(height: AppSpacing.xs),

                TextFormField(
                  controller: _descriptionController,
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: 3,
                  maxLength: 500,
                  enabled: !_isLoading,
                  decoration: _inputDecoration(
                    hintText: 'Optional description',
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // ==================================================
                // INFORMATION
                // ==================================================
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.12),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.savings_outlined,
                        size: 20,
                        color: AppColors.primary,
                      ),

                      const SizedBox(width: AppSpacing.sm),

                      Expanded(
                        child: Text(
                          'Creating a goal does not move any money. '
                          'You can add money to this goal separately '
                          'using Add Money.',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // ==================================================
                // CREATE BUTTON
                // ==================================================
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: _isLoading ? null : _createGoal,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Create Goal',
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

  // ============================================================
  // LABEL
  // ============================================================

  Widget _buildLabel(String text) {
    return Text(text, style: AppTextStyles.sectionTitle);
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration _inputDecoration({
    required String hintText,
    String? prefixText,
  }) {
    return InputDecoration(
      hintText: hintText,
      prefixText: prefixText,
      filled: true,
      fillColor: Colors.grey.shade50,

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),

      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
    );
  }

  // ============================================================
  // DATE FORMAT
  // ============================================================

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${date.day} '
        '${months[date.month - 1]} '
        '${date.year}';
  }
}
