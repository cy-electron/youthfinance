import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import 'package:youthfinance/features/analytics/data/financial_health_provider.dart';
import 'package:youthfinance/features/analytics/data/financial_health_summary.dart';
import 'package:youthfinance/features/home/presentation/widgets/health_matric.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../design_system/cards/app_card.dart';

class FinancialHealthCard extends ConsumerWidget {
  final VoidCallback? onNavigateToInsights;

  const FinancialHealthCard({
    super.key,
    this.onNavigateToInsights,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final healthState = ref.watch(financialHealthProvider);

    return AppCard(
      child: healthState.when(
        loading: () {
          return const SizedBox(
            height: 360,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        },

        error: (error, stack) {
          return const SizedBox(
            height: 360,
            child: Center(
              child: Text('Unable to load financial health'),
            ),
          );
        },

        data: (health) {
          return _FinancialHealthContent(
            health: health,
            onNavigateToInsights: onNavigateToInsights,
          );
        },
      ),
    );
  }
}

// ============================================================
// Financial Health Content
// ============================================================

class _FinancialHealthContent extends StatelessWidget {
  final FinancialHealthSummary health;
  final VoidCallback? onNavigateToInsights;

  const _FinancialHealthContent({
    required this.health,
    this.onNavigateToInsights,
  });

  @override
  Widget build(BuildContext context) {
    final score = health.score.clamp(0, 100).toDouble();
    final scoreColor = _scoreColor(score);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ====================================================
          // Header
          // ====================================================
          Row(
            children: [
              Text(
                "FINANCIAL HEALTH",
                style: AppTextStyles.sectionTitle,
              ),

              const SizedBox(width: 6),

              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => _showFinancialHealthInfo(context),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.info_outline,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),

              const Spacer(),

              InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: onNavigateToInsights,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.border,
                    ),
                  ),
                  child: const Icon(
                    Icons.chevron_right,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // ====================================================
          // Main Score
          // ====================================================
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircularPercentIndicator(
                radius: 72,
                lineWidth: 12,
                percent: score / 100,
                animation: true,
                animationDuration: 1200,
                circularStrokeCap: CircularStrokeCap.round,
                progressColor: scoreColor,
                backgroundColor: const Color(0xFFE8EDF3),

                center: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      score.round().toString(),
                      style: AppTextStyles.heading.copyWith(
                        fontSize: 42,
                        height: 1,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      "/100",
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 28),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: scoreColor.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _healthStatus(score),
                        style: AppTextStyles.cardTitle.copyWith(
                          color: scoreColor,
                          fontSize: 22,
                          height: 1.1,
                        ),
                        softWrap: true,
                      ),
                    ),


                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // ====================================================
          // Financial Health Metrics
          // ====================================================
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HealthMetric(
                icon: Icons.savings,
                title: "Savings",
                status: _metricStatus(
                  health.savings,
                  20,
                ),
                progress: _metricProgress(
                  health.savings,
                  20,
                ),
                color: _metricColor(
                  health.savings,
                  20,
                ),
              ),

              const SizedBox(width: AppSpacing.md),

              HealthMetric(
                icon: Icons.account_balance_wallet,
                title: "Budget",
                status: _metricStatus(
                  health.budget,
                  20,
                ),
                progress: _metricProgress(
                  health.budget,
                  20,
                ),
                color: _metricColor(
                  health.budget,
                  20,
                ),
              ),

              const SizedBox(width: AppSpacing.md),

              HealthMetric(
                icon: Icons.flag,
                title: "Goals",
                status: _metricStatus(
                  health.goals,
                  20,
                ),
                progress: _metricProgress(
                  health.goals,
                  20,
                ),
                color: _metricColor(
                  health.goals,
                  20,
                ),
              ),

              const SizedBox(width: AppSpacing.md),

              HealthMetric(
                icon: Icons.security,
                title: "Emergency",
                status: _metricStatus(
                  health.emergency,
                  10,
                ),
                progress: _metricProgress(
                  health.emergency,
                  10,
                ),
                color: _metricColor(
                  health.emergency,
                  10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // Financial Health Information
  // ==========================================================

  void _showFinancialHealthInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Financial Health"),

          content: const Text(
            "Your Financial Health score is a 100-point "
            "snapshot of your overall financial habits "
            "and stability.\n\n"
            "Your score is based on 8 areas:\n\n"
            "• Savings Habit — 20 points\n"
            "• Budget Discipline — 15 points\n"
            "• Goal Progress — 20 points\n"
            "• Income Stability — 10 points\n"
            "• Expense Stability — 10 points\n"
            "• Emergency Fund — 10 points\n"
            "• Investment Habit — 5 points\n"
            "• Fun Fund — 5 points\n\n"
            "Each area contributes to your total score "
            "based on your current financial activity "
            "and progress.\n\n"
            "Tip: Focus first on the areas where your "
            "score is lower or marked \"Needs Attention\". "
            "Improving those areas can help strengthen "
            "your overall financial health.",
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Got it"),
            ),
          ],
        );
      },
    );
  }

  // ==========================================================
  // Overall Health Status
  // ==========================================================

  String _healthStatus(double score) {
    if (score >= 80) {
      return "Excellent";
    }

    if (score >= 60) {
      return "Good";
    }

    return "Needs Attention";
  }

  // ==========================================================
  // Overall Score Color
  // ==========================================================

  Color _scoreColor(double score) {
    if (score >= 80) {
      return const Color(0xFF10B981); // Excellent
    }

    if (score >= 60) {
      return const Color(0xFF3B82F6); // Good
    }

    if (score >= 40) {
      return const Color(0xFFF59E0B); // Fair
    }

    return const Color(0xFFEF4444); // Needs Attention
  }

  // ==========================================================
  // Component Progress
  // ==========================================================

  double _metricProgress(
    double value,
    double maximum,
  ) {
    if (maximum <= 0) {
      return 0;
    }

    return (value / maximum).clamp(0.0, 1.0);
  }

  // ==========================================================
  // Component Status
  // ==========================================================

  String _metricStatus(
    double value,
    double maximum,
  ) {
    final progress = _metricProgress(
      value,
      maximum,
    );

    if (progress >= 0.80) {
      return "Excellent";
    }

    if (progress >= 0.60) {
      return "Good";
    }

    if (progress >= 0.40) {
      return "Fair";
    }

    return "Needs Attention";
  }

  // ==========================================================
  // Component Color
  // ==========================================================

  Color _metricColor(
    double value,
    double maximum,
  ) {
    final progress = _metricProgress(
      value,
      maximum,
    );

    if (progress >= 0.80) {
      return const Color(0xFF10B981); // Excellent
    }

    if (progress >= 0.60) {
      return const Color(0xFF3B82F6); // Good
    }

    if (progress >= 0.40) {
      return const Color(0xFFF59E0B); // Fair
    }

    return const Color(0xFFEF4444); // Needs Attention
  }
}