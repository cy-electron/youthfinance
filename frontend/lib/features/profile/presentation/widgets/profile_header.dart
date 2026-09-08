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
      loading: () => const _ProfileHeaderSkeleton(),

      // ========================================================
      // Error
      // ========================================================
      error: (error, stackTrace) {
        return Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.14),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(
                Icons.person_outline_rounded,
                color: AppColors.primary,
                size: 20,
              ),
            ),
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
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.14),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.person_outline_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Text("Guest", style: AppTextStyles.heading),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
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
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    user.fullName,
                    style: AppTextStyles.heading.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                      height: 1.15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          _profileSubtitle(user),
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            letterSpacing: 0.1,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: AppSpacing.sm),

            // ==================================================
            // Edit Profile
            // ==================================================
            _EditProfileButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const EditProfileScreen(),
                  ),
                );
              },
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
// Initials Avatar — light mint fill, emerald text (your existing
// color concept), just tighter and smaller. Separation from the
// cream background comes from a soft, tinted shadow — not a ring
// or border, which read as a badge rather than an avatar.
// ============================================================

class _InitialsAvatar extends StatelessWidget {
  final String fullName;

  const _InitialsAvatar({required this.fullName});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 55,
      height: 55,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primaryLight,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.16),
            blurRadius: 3,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        _getInitials(fullName),
        style: AppTextStyles.cardTitle.copyWith(
          color: AppColors.primary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
          height: 1,
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

// ============================================================
// Edit Profile Button — restrained, hairline outline, no fill.
// A financial product shouldn't have a loud, filled action
// button competing with the identity block next to it.
// ============================================================

class _EditProfileButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _EditProfileButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        splashColor: AppColors.primaryDark.withOpacity(0.08),
        highlightColor: AppColors.primaryDark.withOpacity(0.04),
        child: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primaryDark.withOpacity(0.20),
              width: 1,
            ),
          ),
          child: Icon(
            Icons.edit_outlined,
            size: 16,
            color: AppColors.primaryDark.withOpacity(0.75),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// Loading Skeleton — shimmer-style placeholder, no spinner
// ============================================================

class _ProfileHeaderSkeleton extends StatefulWidget {
  const _ProfileHeaderSkeleton();

  @override
  State<_ProfileHeaderSkeleton> createState() =>
      _ProfileHeaderSkeletonState();
}

class _ProfileHeaderSkeletonState extends State<_ProfileHeaderSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Slow, subtle pulse — not a shiny sweep. Reads as
        // "content is settling in", not a game loading screen.
        final opacity = 0.10 + 0.08 * (1 - (_controller.value - 0.5).abs() * 2);
        return Row(
          children: [
            _shimmerBox(width: 60, height: 60, radius: 30, opacity: opacity),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _shimmerBox(width: 130, height: 14, radius: 4, opacity: opacity),
                  const SizedBox(height: 8),
                  _shimmerBox(width: 84, height: 11, radius: 4, opacity: opacity),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _shimmerBox({
    required double width,
    required double height,
    required double radius,
    required double opacity,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.primaryDark.withOpacity(opacity),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}