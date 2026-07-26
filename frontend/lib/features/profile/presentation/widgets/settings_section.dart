import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../design_system/cards/app_card.dart';

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
            children: const [
              ListTile(
                leading: Icon(Icons.palette_outlined),
                title: Text("Appearance"),
                trailing: Icon(Icons.chevron_right),
              ),

              Divider(),

              ListTile(
                leading: Icon(Icons.notifications_none),
                title: Text("Notifications"),
                trailing: Icon(Icons.chevron_right),
              ),

              Divider(),

              ListTile(
                leading: Icon(Icons.lock_outline),
                title: Text("Privacy & Security"),
                trailing: Icon(Icons.chevron_right),
              ),

              Divider(),

              ListTile(
                leading: Icon(Icons.file_download_outlined),
                title: Text("Export Data"),
                trailing: Icon(Icons.chevron_right),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
