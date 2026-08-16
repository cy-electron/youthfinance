import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youthfinance/features/auth/providers/auth_provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

class ProfileHeader extends ConsumerWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return authState.when(
      loading: () {
        return const Row(
          children: [
            CircleAvatar(radius: 34, child: CircularProgressIndicator()),
            SizedBox(width: AppSpacing.lg),
            Text("Loading profile..."),
          ],
        );
      },

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

      data: (user) {
        if (user == null) {
          return Row(
            children: [
              const CircleAvatar(radius: 34, child: Icon(Icons.person_outline)),

              const SizedBox(width: AppSpacing.lg),

              Text("Guest", style: AppTextStyles.heading),
            ],
          );
        }

        return Row(
          children: [
            Stack(
              children: [
                const CircleAvatar(
                  radius: 34,
                  backgroundImage: NetworkImage(
                    "https://i.pravatar.cc/150?img=12",
                  ),
                ),

                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const CircleAvatar(
                      radius: 8,
                      backgroundColor: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(width: AppSpacing.lg),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.fullName, style: AppTextStyles.heading),

                  const SizedBox(height: 4),

                  Text(
                    "Building healthy financial habits",
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),

            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.edit_outlined),
              ),
            ),
          ],
        );
      },
    );
  }
}
