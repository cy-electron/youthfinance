import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Stack(
          children: [
            const CircleAvatar(
              radius: 34,
              backgroundImage: NetworkImage("https://i.pravatar.cc/150?img=12"),
            ),

            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
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
              Text("Alex Rivera", style: AppTextStyles.heading),

              const SizedBox(height: 4),

              Text(
                "Building healthy financial habits",
                style: AppTextStyles.body.copyWith(color: AppColors.primary),
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
  }
}
