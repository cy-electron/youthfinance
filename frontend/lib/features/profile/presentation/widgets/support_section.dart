import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../design_system/cards/app_card.dart';

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
            children: const [
              ListTile(
                title: Text("Help Center"),
                trailing: Icon(Icons.chevron_right),
              ),

              Divider(),

              ListTile(title: Text("FAQ"), trailing: Icon(Icons.chevron_right)),

              Divider(),

              ListTile(
                title: Text("Privacy Policy"),
                trailing: Icon(Icons.chevron_right),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
