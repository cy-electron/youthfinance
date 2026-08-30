import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../design_system/buttons/app_icon_button.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../profile/presentation/widgets/user_initials_avatar.dart';

class GreetingSection extends ConsumerWidget {
  final VoidCallback? onNotificationsTap;
  final bool hasUnreadNotifications;

  const GreetingSection({
    super.key,
    this.onNotificationsTap,
    this.hasUnreadNotifications = true,
  });

  String _getGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return 'Good morning,';
    }

    if (hour < 17) {
      return 'Good afternoon,';
    }

    return 'Good evening,';
  }

  String _getFirstName(String? fullName) {
    if (fullName == null || fullName.trim().isEmpty) {
      return 'there';
    }

    return fullName.trim().split(RegExp(r'\s+')).first;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.valueOrNull;

    final fullName = user?.fullName ?? '';
    final firstName = _getFirstName(user?.fullName);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ======================================================
        // USER AVATAR
        // ======================================================
        UserInitialsAvatar(
          fullName: fullName.isEmpty ? "User" : fullName,
          radius: 26,
        ),

        const SizedBox(width: AppSpacing.md),

        // ======================================================
        // GREETING
        // ======================================================
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_getGreeting(), style: AppTextStyles.greeting),

              const SizedBox(height: AppSpacing.xs),

              Text(
                '$firstName 👋',
                style: AppTextStyles.heading.copyWith(fontSize: 22),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),

        const SizedBox(width: AppSpacing.sm),

        // ======================================================
        // NOTIFICATIONS
        // ======================================================
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
