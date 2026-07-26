import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../design_system/cards/app_card.dart';

class HealthTrendChart extends StatelessWidget {
  const HealthTrendChart({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Financial Health Trend", style: AppTextStyles.sectionTitle),

              Text(
                "+10 pts",
                style: AppTextStyles.caption.copyWith(color: AppColors.primary),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                minY: 60,
                maxY: 100,

                borderData: FlBorderData(show: false),

                gridData: FlGridData(drawVerticalLine: false),

                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(),

                  rightTitles: const AxisTitles(),

                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,

                      getTitlesWidget: (value, meta) {
                        const months = [
                          "Apr",
                          "May",
                          "Jun",
                          "Jul",
                          "Aug",
                          "Sep",
                        ];

                        return Text(
                          months[value.toInt()],
                          style: AppTextStyles.caption,
                        );
                      },
                    ),
                  ),
                ),

                lineBarsData: [
                  LineChartBarData(
                    isCurved: true,

                    color: AppColors.primary,

                    barWidth: 4,

                    dotData: const FlDotData(show: false),

                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.primary.withOpacity(.10),
                    ),

                    spots: const [
                      FlSpot(0, 72),

                      FlSpot(1, 76),

                      FlSpot(2, 81),

                      FlSpot(3, 84),

                      FlSpot(4, 82),

                      FlSpot(5, 88),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
