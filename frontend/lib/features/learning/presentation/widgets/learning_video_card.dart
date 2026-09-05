import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_spacing.dart';
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
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
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

                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                  errorBuilder: (_, __, ___) {
                    return const Center(
                      child: Icon(
                        Icons.play_circle_outline,
                        size: 56,
                      ),
                    );
                  },
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _openVideo(context),
                    child: const Center(
                      child: CircleAvatar(
                        radius: 28,
                        child: Icon(
                          Icons.play_arrow,
                          size: 32,
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
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),

                const SizedBox(height: AppSpacing.xs),

                Text(
                  resource.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),

                const SizedBox(height: AppSpacing.sm),

                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  children: [
                    _InfoChip(
                      icon: Icons.schedule_outlined,
                      label: resource.duration,
                    ),
                    _InfoChip(
                      icon: Icons.school_outlined,
                      label: resource.difficulty,
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.md),

                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => _openVideo(context),
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Watch on YouTube'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    IconButton(
                      tooltip: isCompleted
                          ? 'Completed'
                          : 'Mark as done',
                      onPressed:
                          isCompleted ? null : onMarkDone,
                      icon: Icon(
                        isCompleted
                            ? Icons.check_circle
                            : Icons.check_circle_outline,
                      ),
                    ),
                  ],
                ),

                if (isCompleted) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Completed',
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: Theme.of(context)
              .colorScheme
              .onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Text(label),
      ],
    );
  }
}