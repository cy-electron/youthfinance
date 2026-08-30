import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:youthfinance/features/analytics/data/financial_health_provider.dart';
import 'package:youthfinance/features/analytics/data/financial_health_summary.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../design_system/cards/app_card.dart';

class HealthTrendChart extends ConsumerWidget {
  const HealthTrendChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final healthState = ref.watch(financialHealthProvider);

    return AppCard(
      child: healthState.when(
        loading: () {
          return const SizedBox(
            height: 300,
            child: Center(child: CircularProgressIndicator()),
          );
        },

        error: (error, stack) {
          return const SizedBox(
            height: 300,
            child: Center(child: Text('Unable to load financial health')),
          );
        },

        data: (health) {
          return _FinancialHealthContent(health: health);
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

  const _FinancialHealthContent({required this.health});

  @override
  Widget build(BuildContext context) {
    final score = health.score.clamp(0, 100).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ======================================================
        // Header
        // ======================================================
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Financial Health', style: AppTextStyles.sectionTitle),

                  const SizedBox(height: AppSpacing.xs),

                  Text(
                    'Your current financial health',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),

            const SizedBox(width: AppSpacing.sm),

            Text(
              '${score.round()}/100',
              style: AppTextStyles.cardTitle.copyWith(color: AppColors.primary),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.lg),

        // ======================================================
        // Score Chart
        // ======================================================
        SizedBox(
          height: 230,
          child: LineChart(
            LineChartData(
              minX: 0,
              maxX: 1,

              minY: 0,
              maxY: 100,

              borderData: FlBorderData(show: false),

              // ------------------------------------------------
              // Grid
              // ------------------------------------------------
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 20,

                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.grey.shade300,
                    strokeWidth: 1,
                    dashArray: [6, 5],
                  );
                },
              ),

              // ------------------------------------------------
              // Axis titles
              // ------------------------------------------------
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),

                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),

                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 38,
                    interval: 20,

                    getTitlesWidget: (value, meta) {
                      return Text(
                        '${value.toInt()}',
                        style: AppTextStyles.caption.copyWith(fontSize: 10),
                      );
                    },
                  ),
                ),

                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 32,

                    getTitlesWidget: (value, meta) {
                      if (value == 0) {
                        return SideTitleWidget(
                          meta: meta,
                          space: 8,
                          child: Text(
                            'Current',
                            style: AppTextStyles.caption.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),

              // ------------------------------------------------
              // Touch
              // ------------------------------------------------
              lineTouchData: LineTouchData(
                enabled: true,
                handleBuiltInTouches: true,

                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (spots) {
                    return spots.map((spot) {
                      return LineTooltipItem(
                        'Financial Health\n'
                        '${score.round()}/100',
                        const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    }).toList();
                  },
                ),
              ),

              // ------------------------------------------------
              // Current score
              // ------------------------------------------------
              lineBarsData: [
                LineChartBarData(
                  isCurved: false,

                  color: AppColors.primary,

                  barWidth: 4,

                  isStrokeCapRound: true,

                  dotData: FlDotData(
                    show: true,

                    getDotPainter: (spot, percent, bar, index) {
                      return FlDotCirclePainter(
                        radius: 6,
                        color: AppColors.primary,
                        strokeWidth: 3,
                        strokeColor: Colors.white,
                      );
                    },
                  ),

                  belowBarData: BarAreaData(
                    show: true,
                    color: AppColors.primary.withValues(alpha: 0.08),
                  ),

                  // IMPORTANT:
                  // Both points represent the SAME current
                  // backend score. No fake historical data.
                  spots: [FlSpot(0, score), FlSpot(1, score)],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.sm),

        // ======================================================
        // Current evaluation
        // ======================================================
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: _healthColor(score),
                shape: BoxShape.circle,
              ),
            ),

            const SizedBox(width: 7),

            Text(
              _healthLabel(score),
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
            ),

            const Spacer(),

            Text('Current evaluation', style: AppTextStyles.caption),
          ],
        ),

        const SizedBox(height: AppSpacing.sm),

        // ======================================================
        // Explanation
        // ======================================================
        Text(
          'Calculated from your savings, budget, goals, '
          'income, expenses, emergency fund, investments '
          'and fun fund.',
          style: AppTextStyles.caption,
        ),
      ],
    );
  }

  // ============================================================
  // Health Label
  // ============================================================

  String _healthLabel(double score) {
    if (score >= 80) {
      return 'Strong';
    }

    if (score >= 60) {
      return 'Good';
    }

    if (score >= 40) {
      return 'Fair';
    }

    return 'Needs attention';
  }

  // ============================================================
  // Health Color
  // ============================================================

  Color _healthColor(double score) {
    if (score >= 80) {
      return AppColors.primary;
    }

    if (score >= 60) {
      return Colors.orange;
    }

    return Colors.redAccent;
  }
}
