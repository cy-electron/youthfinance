import 'package:flutter/material.dart';

import '../../model/fun_fund_model.dart';

class FunFundCard extends StatelessWidget {
  final FunFundModel fund;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const FunFundCard({
    super.key,
    required this.fund,
    this.onEdit,
    this.onDelete,
  });

  String _formatDate(DateTime? date) {
    if (date == null) return 'No date set';

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ======================================================
            // HEADER
            // ======================================================

            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    Icons.celebration_outlined,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fund.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'From monthly budget',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color
                              ?.withValues(alpha: 0.65),
                        ),
                      ),
                    ],
                  ),
                ),

                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_horiz),
                  onSelected: (value) {
                    if (value == 'edit') {
                      onEdit?.call();
                    }

                    if (value == 'delete') {
                      onDelete?.call();
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined),
                          SizedBox(width: 12),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline),
                          SizedBox(width: 12),
                          Text('Delete'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ======================================================
            // MONEY
            // ======================================================

            Row(
              children: [
                Expanded(
                  child: _MoneyInfo(
                    label: 'Set aside',
                    amount: fund.currentAmount,
                  ),
                ),
                Expanded(
                  child: _MoneyInfo(
                    label: 'Planned',
                    amount: fund.targetAmount,
                    alignment: CrossAxisAlignment.end,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // ======================================================
            // SIMPLE INFO ROW
            // ======================================================

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatDate(fund.targetDate),
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const Spacer(),

                  if (fund.remainingAmount > 0)
                    Text(
                      '₹${fund.remainingAmount.toStringAsFixed(2)} available',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),

            // ======================================================
            // NOTES
            // ======================================================

            if (fund.notes != null &&
                fund.notes!.trim().isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(
                fund.notes!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MoneyInfo extends StatelessWidget {
  final String label;
  final double amount;
  final CrossAxisAlignment alignment;

  const _MoneyInfo({
    required this.label,
    required this.amount,
    this.alignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.textTheme.bodySmall?.color
                ?.withValues(alpha: 0.65),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          '₹${amount.toStringAsFixed(2)}',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}