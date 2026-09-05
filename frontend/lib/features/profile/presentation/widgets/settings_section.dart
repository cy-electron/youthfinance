import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../design_system/cards/app_card.dart';
import 'package:go_router/go_router.dart';

class SettingsSection extends StatelessWidget {
  const SettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("  Settings", style: AppTextStyles.sectionTitle),

        const SizedBox(height: AppSpacing.sm),

        AppCard(
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.palette_outlined),
                title: const Text("Appearance"),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/settings/appearance'),
              ),

              const Divider(),

              ListTile(
                leading: Icon(Icons.notifications_none),
                title: const Text("Notifications"),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/settings/notifications'),
              ),

              const Divider(),

              ListTile(
                leading: Icon(Icons.lock_outline),
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
