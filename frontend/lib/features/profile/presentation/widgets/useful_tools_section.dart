import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'useful_tools_chip.dart';


class UsefulToolsSection extends StatelessWidget {
  const UsefulToolsSection({super.key});

  void _showComingSoon(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(feature),
          content: Text(
            '$feature is coming soon. '
            'We are working on bringing this feature to YouthFinance.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Got it'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Useful tools", style: AppTextStyles.sectionTitle),

        const SizedBox(height: AppSpacing.sm),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              UsefulToolsChip(
                icon: Icons.import_export,
                title: "Import data",
                onTap: () => _showComingSoon(context, "Import Data"),
              ),

              const SizedBox(width: 8),

              UsefulToolsChip(
                icon: Icons.celebration_outlined,
                title: "Fun Fund",
                onTap: () => context.push('/fun-fund'),
              ),

              const SizedBox(width: 8),

              UsefulToolsChip(
                icon: Icons.savings_outlined,
                title: "Emergency\nFund",
                onTap: () => context.push('/emergency-fund'),
              ),

              const SizedBox(width: 8),

              UsefulToolsChip(
                icon: Icons.trending_up_outlined,
                title: "Investment",
                onTap: () => context.push('/investments'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
