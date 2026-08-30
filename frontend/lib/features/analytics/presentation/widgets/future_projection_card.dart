import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:youthfinance/features/transactions/model/transaction_model.dart';
import 'package:youthfinance/features/transactions/model/transaction_provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../design_system/cards/app_card.dart';

class FutureProjectionCard extends ConsumerWidget {
  const FutureProjectionCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionState = ref.watch(transactionProvider);

    return AppCard(
      color: AppColors.primary,
      child: transactionState.when(
        loading: () {
          return const SizedBox(
            height: 170,
            child: Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
        },

        error: (error, stack) {
          return const SizedBox(
            height: 170,
            child: Center(
              child: Text(
                'Unable to calculate projection',
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        },

        data: (transactions) {
          if (transactions.isEmpty) {
            return _EmptyProjection();
          }

          final projection = _calculateProjection(transactions);

          return _ProjectionContent(projection: projection);
        },
      ),
    );
  }

  // ==========================================================
  // Projection Calculation
  // ==========================================================

  _ProjectionData _calculateProjection(List<TransactionModel> transactions) {
    final now = DateTime.now();

    double totalIncome = 0;
    double totalExpense = 0;

    // --------------------------------------------------------
    // Calculate current total savings
    // --------------------------------------------------------

    for (final transaction in transactions) {
      if (transaction.date.isAfter(now)) {
        continue;
      }

      if (transaction.isIncome) {
        totalIncome += transaction.amount;
      } else {
        totalExpense += transaction.amount;
      }
    }

    final currentSavings = totalIncome - totalExpense;

    // --------------------------------------------------------
    // Calculate months represented by the user's data
    // --------------------------------------------------------

    final validTransactions = transactions
        .where((transaction) => !transaction.date.isAfter(now))
        .toList();

    if (validTransactions.isEmpty) {
      return const _ProjectionData(
        projectedSavings: 0,
        monthsAhead: 6,
        status: 'No data',
      );
    }

    validTransactions.sort((a, b) => a.date.compareTo(b.date));

    final firstDate = validTransactions.first.date;

    final firstMonth = DateTime(firstDate.year, firstDate.month);

    final currentMonth = DateTime(now.year, now.month);

    final monthsOfHistory =
        (currentMonth.year - firstMonth.year) * 12 +
        currentMonth.month -
        firstMonth.month +
        1;

    // --------------------------------------------------------
    // Calculate average monthly savings
    // --------------------------------------------------------

    final averageMonthlySavings = currentSavings / monthsOfHistory;

    // --------------------------------------------------------
    // Project 6 months forward
    //
    // This is deliberately simple for V1:
    // current savings + average monthly savings × 6
    // --------------------------------------------------------

    const projectionMonths = 6;

    double projectedSavings =
        currentSavings + (averageMonthlySavings * projectionMonths);

    // Prevent a negative projection from looking like
    // a positive savings goal.
    if (projectedSavings < 0) {
      projectedSavings = 0;
    }

    // --------------------------------------------------------
    // Determine status
    // --------------------------------------------------------

    String status;

    if (averageMonthlySavings > 0) {
      status = 'On Track';
    } else if (averageMonthlySavings == 0) {
      status = 'Steady';
    } else {
      status = 'Needs Attention';
    }

    return _ProjectionData(
      projectedSavings: projectedSavings,
      monthsAhead: projectionMonths,
      status: status,
    );
  }
}

// ============================================================
// Projection Content
// ============================================================

class _ProjectionContent extends StatelessWidget {
  final _ProjectionData projection;

  const _ProjectionContent({required this.projection});

  @override
  Widget build(BuildContext context) {
    final targetDate = DateTime(
      DateTime.now().year,
      DateTime.now().month + projection.monthsAhead,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ----------------------------------------------------
        // Header
        // ----------------------------------------------------
        Text(
          "Where You're Headed",
          style: AppTextStyles.cardTitle.copyWith(color: Colors.white),
        ),

        const SizedBox(height: AppSpacing.sm),

        // ----------------------------------------------------
        // Projected amount
        // ----------------------------------------------------
        Text(
          _formatAmount(projection.projectedSavings),
          style: AppTextStyles.heading.copyWith(
            color: Colors.white,
            fontSize: 42,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: AppSpacing.xs),

        Text(
          'Estimated savings by ${_formatDate(targetDate)}',
          style: AppTextStyles.body.copyWith(color: Colors.white70),
        ),

        const SizedBox(height: AppSpacing.lg),

        // ----------------------------------------------------
        // Status
        // ----------------------------------------------------
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 9,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                projection.status == 'On Track'
                    ? Icons.trending_up_rounded
                    : Icons.insights_outlined,
                size: 16,
                color: Colors.white,
              ),

              const SizedBox(width: 7),

              Text(
                'Based on your current pace',
                style: AppTextStyles.caption.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(width: 8),

              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: Colors.white54,
                  shape: BoxShape.circle,
                ),
              ),

              const SizedBox(width: 8),

              Text(
                projection.status,
                style: AppTextStyles.caption.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatAmount(double amount) {
    if (amount >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(1)}L';
    }

    if (amount >= 1000) {
      return '₹${(amount / 1000).toStringAsFixed(1)}K';
    }

    return '₹${amount.toStringAsFixed(0)}';
  }

  String _formatDate(DateTime date) {
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

    return '${months[date.month - 1]} ${date.year}';
  }
}

// ============================================================
// Empty State
// ============================================================

class _EmptyProjection extends StatelessWidget {
  const _EmptyProjection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Where You're Headed",
          style: AppTextStyles.cardTitle.copyWith(color: Colors.white),
        ),

        const SizedBox(height: AppSpacing.sm),

        Text(
          'Add some transactions',
          style: AppTextStyles.heading.copyWith(
            color: Colors.white,
            fontSize: 28,
          ),
        ),

        const SizedBox(height: AppSpacing.xs),

        Text(
          'We’ll use your financial activity to estimate your future savings.',
          style: AppTextStyles.body.copyWith(color: Colors.white70),
        ),
      ],
    );
  }
}

// ============================================================
// Projection Data
// ============================================================

class _ProjectionData {
  final double projectedSavings;
  final int monthsAhead;
  final String status;

  const _ProjectionData({
    required this.projectedSavings,
    required this.monthsAhead,
    required this.status,
  });
}
