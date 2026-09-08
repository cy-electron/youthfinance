import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../model/learning_resource.dart';

class LearningVideoCard extends StatelessWidget {
  final LearningResource resource;
  final bool isCompleted;
  final VoidCallback onMarkDone;

  const LearningVideoCard({
    super.key,
    required this.resource,
    required this.isCompleted,
    required this.onMarkDone,
  });

  Future<void> _openVideo(BuildContext context) async {
    final uri = Uri.tryParse(resource.youtubeUrl);

    if (uri == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This video link is not available.'),
        ),
      );
      return;
    }

    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to open YouTube.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  resource.thumbnailUrl,
                  fit: BoxFit.cover,
                  loadingBuilder:
                      (context, child, loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    }

                    return Container(
                      color: AppColors.primaryLight,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                          strokeWidth: 2.5,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (_, __, ___) {
                    return Container(
                      color: AppColors.primaryLight,
                      child: Icon(
                        Icons.play_circle_outline,
                        size: 48,
                        color: AppColors.primary,
                      ),
                    );
                  },
                ),

                // Subtle bottom gradient so a badge or the play
                // control never fights with a busy thumbnail.
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Color(0x33000000),
                      ],
                      stops: [0.55, 1.0],
                    ),
                  ),
                ),

                // Duration badge, overlaid bottom-right — the
                // conventional spot on any video thumbnail.
                Positioned(
                  right: 10,
                  bottom: 10,
                  child: _Badge(
                    icon: Icons.schedule_rounded,
                    label: resource.duration,
                    dark: true,
                  ),
                ),

                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _openVideo(context),
                    child: Center(
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryDark,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          size: 32,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  resource.title,
                  style: AppTextStyles.body.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),

                const SizedBox(height: AppSpacing.xs),

                Text(
                  resource.description,
                  style: AppTextStyles.body.copyWith(
                    fontSize: 13,
                    color: Colors.black54,
                    height: 1.35,
                  ),
                ),

                const SizedBox(height: AppSpacing.sm),

                _Badge(
                  icon: Icons.school_rounded,
                  label: resource.difficulty,
                  dark: false,
                ),

                const SizedBox(height: AppSpacing.md),

                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primaryDark,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => _openVideo(context),
                          icon: const Icon(
                            Icons.play_arrow_rounded,
                            size: 20,
                          ),
                          label: const Text(
                            'Watch on YouTube',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13.5,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: AppSpacing.sm),

                    _MarkDoneButton(
                      isCompleted: isCompleted,
                      onPressed: isCompleted ? null : onMarkDone,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Small info badge — duration (dark, sits on the thumbnail) and
// difficulty (tonal, sits on the white card body). Same shape,
// different weight, so they read as one system.
// ============================================================

class _Badge extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool dark;

  const _Badge({
    required this.icon,
    required this.label,
    required this.dark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: dark
            ? Colors.black.withOpacity(0.55)
            : AppColors.primaryLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color: dark ? Colors.white : AppColors.primaryDark,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: dark ? Colors.white : AppColors.primaryDark,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Mark-as-done control — hairline circle that fills solid
// emerald with a check once completed, instead of a plain
// IconButton toggling between two outline icons.
// ============================================================

class _MarkDoneButton extends StatelessWidget {
  final bool isCompleted;
  final VoidCallback? onPressed;

  const _MarkDoneButton({
    required this.isCompleted,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: isCompleted ? 'Completed' : 'Mark as done',
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted
                  ? AppColors.primaryDark
                  : Colors.transparent,
              border: Border.all(
                color: isCompleted
                    ? Colors.transparent
                    : AppColors.primary.withOpacity(0.35),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.check_rounded,
              size: 20,
              color: isCompleted ? Colors.white : AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}