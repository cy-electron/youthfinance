import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'transaction_tile.dart';

class TransactionGroup extends StatelessWidget {
  final String title;

  final List<TransactionTile> transactions;

  const TransactionGroup({
    super.key,
    required this.title,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: AppTextStyles.caption.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        ...transactions,

        const SizedBox(height: 24),
      ],
    );
  }
}
