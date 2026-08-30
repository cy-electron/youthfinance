import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youthfinance/features/auth/providers/auth_provider.dart';
import 'package:youthfinance/features/profile/presentation/widgets/edit_profile_screen.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

class ProfileHeader extends ConsumerWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return authState.when(
      // ========================================================
      // Loading
      // ========================================================
      loading: () {
        return const Row(
          children: [
            CircleAvatar(radius: 34, child: CircularProgressIndicator()),
            SizedBox(width: AppSpacing.lg),
            Text("Loading profile..."),
          ],
        );
      },

      // ========================================================
      // Error
      // ========================================================
      error: (error, stackTrace) {
        return Row(
          children: [
            const CircleAvatar(radius: 34, child: Icon(Icons.person_outline)),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Text(
                "Unable to load profile",
                style: AppTextStyles.heading,
              ),
            ),
          ],
        );
      },

      // ========================================================
      // Profile data
      // ========================================================
      data: (user) {
        if (user == null) {
          return Row(
            children: [
              const CircleAvatar(radius: 32, child: Icon(Icons.person_outline)),
              const SizedBox(width: AppSpacing.lg),
              Text("Guest", style: AppTextStyles.heading),
            ],
          );
        }

        return Row(
          children: [
            // ==================================================
            // Initials Avatar
            // ==================================================
            _InitialsAvatar(fullName: user.fullName),

            const SizedBox(width: AppSpacing.md),

            // ==================================================
            // Name + Profile subtitle
            // ==================================================
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.fullName,
                    style: AppTextStyles.heading,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 2),

                  Text(
                    _profileSubtitle(user),
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.primary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const SizedBox(width: AppSpacing.sm),

            // ==================================================
            // Edit Profile
            // ==================================================
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                tooltip: "Edit profile",
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const EditProfileScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.edit_outlined),
              ),
            ),
          ],
        );
      },
    );
  }

  // ==========================================================
  // Profile subtitle
  // ==========================================================

  String _profileSubtitle(user) {
    if (user.occupation != null && user.occupation!.trim().isNotEmpty) {
      return user.occupation!;
    }

    return "Complete your financial profile";
  }
}

// ============================================================
// Initials Avatar
// ============================================================

class _InitialsAvatar extends StatelessWidget {
  final String fullName;

  const _InitialsAvatar({required this.fullName});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 34,
      backgroundColor: AppColors.primaryLight,
      child: Text(
        _getInitials(fullName),
        style: AppTextStyles.cardTitle.copyWith(
          color: AppColors.primary,
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) {
      return "?";
    }

    if (parts.length == 1) {
      final first = parts.first;

      if (first.length >= 2) {
        return first.substring(0, 2).toUpperCase();
      }

      return first.substring(0, 1).toUpperCase();
    }

    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }
}
