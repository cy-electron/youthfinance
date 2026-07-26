import 'package:flutter/material.dart';

import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../cards/app_card.dart';

class ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const ActionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: onTap,
        child: Center(
          // FittedBox is the actual overflow fix: if the tile is ever too
          // narrow/short for the icon + label (different phone widths,
          // font scaling settings, long titles like "Expense"), this
          // scales the whole content down to fit instead of throwing a
          // RenderFlex overflow error. Without this, any mismatch between
          // GridView's childAspectRatio and the real content size breaks.
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CircleAvatar(
                  radius: 38,
                  backgroundColor: color.withValues(alpha: .12),
                  child: Icon(icon, color: color, size: 28),
                ),

                const SizedBox(height: AppSpacing.sm),

                // maxLines + ellipsis: lets "Add Income" wrap onto a
                // second line at the natural word break (not mid-word)
                // when space is tight, instead of forcing a character-level
                // break like "Incom" / "e".
                SizedBox(
                  width: 85,
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body.copyWith(
                      fontSize: 22,
                      height: 1.15,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
