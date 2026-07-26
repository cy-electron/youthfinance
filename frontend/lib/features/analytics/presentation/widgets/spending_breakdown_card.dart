import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../design_system/cards/app_card.dart';

class SpendingBreakdownCard extends StatelessWidget {
  const SpendingBreakdownCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Spending Breakdown", style: AppTextStyles.sectionTitle),
              Text(
                "Sep 2024",
                style: AppTextStyles.caption.copyWith(
                  color: const Color.fromARGB(255, 41, 43, 41),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          SizedBox(
            height: 230,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 4,

                    centerSpaceRadius: 62,

                    borderData: FlBorderData(show: false),

                    sections: [
                      PieChartSectionData(
                        value: 32,
                        color: AppColors.primary,
                        radius: 20,
                        title: "",
                      ),

                      PieChartSectionData(
                        value: 24,
                        color: Colors.blue,
                        radius: 20,
                        title: "",
                      ),

                      PieChartSectionData(
                        value: 18,
                        color: Colors.amber,
                        radius: 20,
                        title: "",
                      ),

                      PieChartSectionData(
                        value: 26,
                        color: Colors.grey.shade400,
                        radius: 20,
                        title: "",
                      ),
                    ],
                  ),
                ),

                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("TOTAL SPEND", style: AppTextStyles.caption),

                    Text("₹28.2K", style: AppTextStyles.heading),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          Wrap(
            spacing: 18,
            runSpacing: 10,
            children: const [
              _Legend(color: AppColors.primary, title: "Food"),

              _Legend(color: Colors.blue, title: "Shopping"),

              _Legend(color: Colors.amber, title: "Bills"),

              _Legend(color: Colors.grey, title: "Others"),
            ],
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;

  final String title;

  const _Legend({required this.color, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(radius: 5, backgroundColor: color),

        const SizedBox(width: 6),

        Text(title, style: AppTextStyles.caption),
      ],
    );
  }
}
