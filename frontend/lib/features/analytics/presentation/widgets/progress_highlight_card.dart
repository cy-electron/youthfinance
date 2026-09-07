import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../design_system/cards/app_card.dart';

import '../../../transactions/model/transaction_model.dart';
import '../../../transactions/model/transaction_provider.dart';

class ProgressHighlightCard extends ConsumerWidget {
  const ProgressHighlightCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsState = ref.watch(transactionProvider);

    return AppCard(
      child: transactionsState.when(
        loading: () => const SizedBox(
          height: 72,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
        error: (_, __) => Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildIcon(),
            const SizedBox(width: AppSpacing.lg),
            const Expanded(
              child: Text(
                'Unable to load your progress.',
                style: AppTextStyles.body,
              ),
            ),
          ],
        ),
        data: (transactions) {
          final highlight = _calculateHighlight(transactions);

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildIcon(),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Progress Highlight',
                      style: AppTextStyles.cardTitle,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      highlight.title,
                      style: AppTextStyles.body,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      highlight.subtitle,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Icon(
        Icons.emoji_events_outlined,
        color: AppColors.primary,
        size: 30,
      ),
    );
  }
}

class _HighlightData {
  final String title;
  final String subtitle;

  const _HighlightData({
    required this.title,
    required this.subtitle,
  });
}

_HighlightData _calculateHighlight(
  List<TransactionModel> transactions,
) {
  final now = DateTime.now();

  final currentMonthTransactions = transactions.where((transaction) {
    return transaction.date.year == now.year &&
        transaction.date.month == now.month;
  }).toList();

  if (currentMonthTransactions.isEmpty) {
    return const _HighlightData(
      title: 'No transactions recorded this month yet.',
      subtitle: 'Add your first income or expense to start tracking.',
    );
  }

  final trackedDays = currentMonthTransactions
      .map(
        (transaction) => DateTime(
          transaction.date.year,
          transaction.date.month,
          transaction.date.day,
        ),
      )
      .toSet()
      .length;

  final transactionCount = currentMonthTransactions.length;

  if (trackedDays == 1) {
    return _HighlightData(
      title: 'You started tracking your finances this month.',
      subtitle: '$transactionCount transaction recorded so far.',
    );
  }

  return _HighlightData(
    title: 'You\'ve tracked your finances on $trackedDays days this month.',
    subtitle:
        '$transactionCount transactions recorded so far. Keep building the habit.',
  );
}