import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../design_system/layout/app_scaffold.dart';

import '../widgets/profile_header.dart';
import '../widgets/useful_tools_section.dart';
import '../widgets/learning_card.dart';
import '../widgets/interest_chips.dart';
import '../widgets/settings_section.dart';
import '../widgets/support_section.dart';
import '../widgets/logout_button.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            // AppScaffold already pads the body with AppSpacing.md, but
            // that alone read as too tight against the status bar for
            // this screen's large avatar + name. A little extra top
            // breathing room before the header fixes it.
            SizedBox(height: AppSpacing.sm),

            ProfileHeader(),

            SizedBox(height: AppSpacing.xl),

            UsefulToolsSection(),

            SizedBox(height: AppSpacing.xl),

            LearningCard(),

            SizedBox(height: AppSpacing.xl),

            InterestChips(),

            SizedBox(height: AppSpacing.xxl),

            SettingsSection(),

            SizedBox(height: AppSpacing.xxl),

            SupportSection(),

            SizedBox(height: AppSpacing.xxl),

            LogoutButton(),

            SizedBox(height: AppSpacing.xxl),

            Center(
              child: Text(
                "YouthFinance v1.0.0",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),

            SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
