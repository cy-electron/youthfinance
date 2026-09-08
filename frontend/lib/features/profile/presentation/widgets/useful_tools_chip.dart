import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

// A card, not a pill. Chips this size with just an icon + label
// read as a browser-default "outlined chip" when they're a flat
// stroked rectangle — wrapping the icon in its own tinted circle
// is what makes it feel like a designed tool tile instead of a
// form control. No boxed background here — the icon circle and
// label float directly on the screen background, so the row reads
// as a set of shortcuts rather than a row of buttons.
class UsefulToolsChip extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const UsefulToolsChip({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        splashColor: AppColors.primary.withOpacity(0.08),
        highlightColor: AppColors.primary.withOpacity(0.04),
        child: Container(
          width: 84,
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.sm,
            horizontal: 4,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon in its own tinted circle — same mint/emerald
              // concept as the profile avatar, so the two feel
              // like one design language. This circle is doing all
              // the "separation from background" work now that
              // there's no card behind it.
              Container(
                width: 44,
                height: 44,
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
                alignment: Alignment.center,
                child: Icon(
                  icon,
                  size: 21,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.body.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  height: 1.15,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}