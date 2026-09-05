import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/theme/app_spacing.dart';
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
      const SnackBar(
        content: Text('Lesson marked as completed.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Learn'),
        ),
        body: Center(
          child: CircularProgressIndicator(),
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
        title: const Text('Learn'),
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
                  fontWeight: FontWeight.w700,
                ),
          ),

          const SizedBox(height: AppSpacing.xs),

          Text(
            'Simple, practical videos to help you '
            'make better financial decisions.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),

          const SizedBox(height: AppSpacing.lg),

          _ProgressCard(
            completed: completedCount,
            total: learningResources.length,
          ),

          const SizedBox(height: AppSpacing.lg),

          Text(
            'Topics',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),

          const SizedBox(height: AppSpacing.sm),

          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    right: AppSpacing.sm,
                  ),
                  child: ChoiceChip(
                    label: const Text('All'),
                    selected: _selectedTopic == null,
                    onSelected: (_) {
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
                    child: ChoiceChip(
                      label: Text(topic),
                      selected: _selectedTopic == topic,
                      onSelected: (_) {
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
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
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

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your learning',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),

            const SizedBox(height: AppSpacing.xs),

            Text(
              '$completed of $total lessons completed',
            ),

            const SizedBox(height: AppSpacing.sm),

            LinearProgressIndicator(
              value: progress,
            ),
          ],
        ),
      ),
    );
  }
}