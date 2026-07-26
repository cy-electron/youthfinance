import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../design_system/buttons/app_icon_button.dart';

class GreetingSection extends StatelessWidget {
  // TODO: wire this up to the real signed-in user (auth/user provider)
  // instead of a hardcoded placeholder.
  final String userName;

  // TODO: wire this up to a real avatar image source (NetworkImage from
  // the user's profile photo URL, or AssetImage for a local default).
  // Left null for now -> falls back to the placeholder circle below.
  final ImageProvider? avatarImage;

  final VoidCallback? onNotificationsTap;
  final bool hasUnreadNotifications;

  const GreetingSection({
    super.key,
    this.userName = "Alex",
    this.avatarImage,
    this.onNotificationsTap,
    this.hasUnreadNotifications = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // ---- Avatar (placeholder until a real image source is wired up) ----
        CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.primaryLight,
          backgroundImage: avatarImage,
          child: avatarImage == null
              ? Icon(Icons.person, color: AppColors.primary)
              : null,
        ),

        const SizedBox(width: AppSpacing.md),

        // ---- "Good morning, / Name 👋" ----
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Good morning,", style: AppTextStyles.greeting),

              const SizedBox(height: AppSpacing.xs),

              Text(
                "$userName 👋",
                style: AppTextStyles.heading.copyWith(fontSize: 22),
              ),
            ],
          ),
        ),

        const SizedBox(width: AppSpacing.sm),

        // ---- Notification bell with unread dot ----
        // Overlaid manually with a Stack since AppIconButton (as used
        // elsewhere in this codebase) doesn't appear to expose a badge
        // parameter. Worth checking app_icon_button.dart — if it already
        // supports a badge, this Stack wrapper can be dropped.
        Stack(
          clipBehavior: Clip.none,
          children: [
            AppIconButton(
              icon: Icons.notifications_none_rounded,
              onTap: onNotificationsTap ?? () {},
            ),

            if (hasUnreadNotifications)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
