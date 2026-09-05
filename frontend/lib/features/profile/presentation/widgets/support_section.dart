import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../design_system/cards/app_card.dart';
import 'package:go_router/go_router.dart';

class SupportSection extends StatelessWidget {
  const SupportSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("  Support", style: AppTextStyles.sectionTitle),

        const SizedBox(height: AppSpacing.sm),

        AppCard(
          child: Column(
            children: [
              ListTile(
                title: const Text("Help Center"),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/support'),
              ),

              const Divider(),

              ListTile(
                title: const Text("FAQ"),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/support/faq'),
              ),

              const Divider(),

              ListTile(
                title: const Text("Privacy Policy"),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/settings/privacy'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
