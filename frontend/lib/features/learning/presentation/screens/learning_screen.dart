import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../widgets/learning_video_card.dart';
import '../../data/learning_content.dart';
import '../../model/learning_resource.dart';

class LearningScreen extends StatefulWidget {
  const LearningScreen({super.key});

  @override
  State<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen> {
  static const String _completedKey =
      'youthfinance_learning_completed';

  final Set<String> _completedIds = <String>{};

  String? _selectedTopic;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCompletedLessons();
  }

  Future<void> _loadCompletedLessons() async {
    final preferences = await SharedPreferences.getInstance();

    final completed =
        preferences.getStringList(_completedKey) ?? <String>[];

    if (!mounted) {
      return;
    }

    setState(() {
      _completedIds
        ..clear()
        ..addAll(completed);
      _isLoading = false;
    });
  }

  Future<void> _markAsDone(
    LearningResource resource,
  ) async {
    if (_completedIds.contains(resource.id)) {
      return;
    }

    final preferences = await SharedPreferences.getInstance();

    final updated = <String>{
      ..._completedIds,
      resource.id,
    };

    await preferences.setStringList(
      _completedKey,
      updated.toList(),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _completedIds
        ..clear()
        ..addAll(updated);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primaryDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        content: const Text('Lesson marked as completed.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Learning Hub'),
          elevation: 0,
        ),
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        ),
      );
    }

    final resources = _selectedTopic == null
        ? learningResources
        : learningResources
            .where(
              (resource) =>
                  resource.topic == _selectedTopic,
            )
            .toList();

    final completedCount = _completedIds
        .where(
          (id) => learningResources.any(
            (resource) => resource.id == id,
          ),
        )
        .length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning Hub'),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
          100,
        ),
        children: [
          Text(
            'Build your financial knowledge',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                  height: 1.2,
                ),
          ),

          const SizedBox(height: AppSpacing.xs),

          Text(
            'Simple, practical videos to help you '
            'make better financial decisions.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.black54,
                  height: 1.35,
                ),
          ),

          const SizedBox(height: AppSpacing.lg),

          _ProgressCard(
            completed: completedCount,
            total: learningResources.length,
          ),

          const SizedBox(height: AppSpacing.lg),

          Text(
            'Topics',
            style: AppTextStyles.sectionTitle,
          ),

          const SizedBox(height: AppSpacing.sm),

          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    right: AppSpacing.sm,
                  ),
                  child: _TopicChip(
                    label: 'All',
                    selected: _selectedTopic == null,
                    onTap: () {
                      setState(() {
                        _selectedTopic = null;
                      });
                    },
                  ),
                ),
                ...learningTopics.map(
                  (topic) => Padding(
                    padding: const EdgeInsets.only(
                      right: AppSpacing.sm,
                    ),
                    child: _TopicChip(
                      label: topic,
                      selected: _selectedTopic == topic,
                      onTap: () {
                        setState(() {
                          _selectedTopic = topic;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          if (_selectedTopic != null)
            Padding(
              padding: const EdgeInsets.only(
                bottom: AppSpacing.md,
              ),
              child: Text(
                _selectedTopic!,
                style: AppTextStyles.sectionTitle,
              ),
            ),

          ...resources.map(
            (resource) => LearningVideoCard(
              resource: resource,
              isCompleted:
                  _completedIds.contains(resource.id),
              onMarkDone: () => _markAsDone(resource),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Progress card — a stat card, not a generic Material Card.
// A ring makes "3 of 12 done" legible at a glance; the text
// version alone made you do the division yourself.
// ============================================================

class _ProgressCard extends StatelessWidget {
  final int completed;
  final int total;

  const _ProgressCard({
    required this.completed,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final progress =
        total == 0 ? 0.0 : completed / total;
    final percent = (progress * 100).round();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 56,
            height: 56,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 56,
                  height: 56,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 5,
                    backgroundColor:
                        AppColors.primary.withOpacity(0.15),
                    valueColor: AlwaysStoppedAnimation(
                      AppColors.primaryDark,
                    ),
                  ),
                ),
                Text(
                  '$percent%',
                  style: AppTextStyles.body.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: AppSpacing.md),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Your learning journey',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$completed of $total lessons completed',
                  style: AppTextStyles.body.copyWith(
                    fontSize: 12.5,
                    color: Colors.black54,
                  ),
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
// Topic chip — filled emerald when selected, hairline outline
// on cream when not. Replaces the default ChoiceChip so topic
// filters look like part of this app instead of stock Material.
// ============================================================

class _TopicChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TopicChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 9,
          ),
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryDark : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected
                  ? Colors.transparent
                  : AppColors.primary.withOpacity(0.25),
              width: 1,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTextStyles.body.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : AppColors.primaryDark,
            ),
          ),
        ),
      ),
    );
  }
}