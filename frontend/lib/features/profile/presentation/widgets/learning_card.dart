import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../design_system/cards/app_card.dart';
import '../../../learning/data/learning_content.dart';

class LearningCard extends StatefulWidget {
  const LearningCard({super.key});

  @override
  State<LearningCard> createState() => _LearningCardState();
}

class _LearningCardState extends State<LearningCard> {
  static const String _completedKey =
      'youthfinance_learning_completed';

  int _completedCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final preferences = await SharedPreferences.getInstance();

    final completedIds =
        preferences.getStringList(_completedKey) ?? <String>[];

    final validCompletedCount = completedIds
        .where(
          (id) => learningResources.any(
            (resource) => resource.id == id,
          ),
        )
        .length;

    if (!mounted) {
      return;
    }

    setState(() {
      _completedCount = validCompletedCount;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final totalLessons = learningResources.length;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //Text(
            //"Continue Learning",
           // style: AppTextStyles.sectionTitle,
          //),

         // const SizedBox(height: AppSpacing.lg),

          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: .10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.school_outlined,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(width: AppSpacing.lg),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Financial Learning",
                      style: AppTextStyles.cardTitle,
                    ),

                    const SizedBox(height: 4),

                    if (_isLoading)
                      Text(
                        "Loading progress...",
                        style: AppTextStyles.caption,
                      )
                    else
                      Text(
                        "$_completedCount of $totalLessons lessons completed",
                        style: AppTextStyles.caption,
                      ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xl),

          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () async {
                await context.push('/learning');

                // Refresh progress when returning from Learning.
                _loadProgress();
              },
              child: const Text("Continue Learning"),
            ),
          ),
        ],
      ),
    );
  }
}