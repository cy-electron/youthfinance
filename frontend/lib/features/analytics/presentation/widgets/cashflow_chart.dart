import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../design_system/cards/app_card.dart';

class CashflowChart extends StatelessWidget {
  const CashflowChart({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Text("Cash Flow Trend", style: AppTextStyles.sectionTitle),

          const SizedBox(height: 24),

          SizedBox(
            height: 220,

            child: LineChart(
              LineChartData(
                borderData: FlBorderData(show: false),

                gridData: FlGridData(show: true, drawVerticalLine: false),

                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(),

                  rightTitles: const AxisTitles(),

                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 34),
                  ),

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

                    dotData: FlDotData(show: false),

                    barWidth: 4,

                    spots: const [
                      FlSpot(0, 38),

                      FlSpot(1, 40),

                      FlSpot(2, 39),

                      FlSpot(3, 41),

                      FlSpot(4, 40),

                      FlSpot(5, 42),
                    ],
                  ),

                  LineChartBarData(
                    isCurved: true,

                    color: Colors.redAccent,

                    dotData: FlDotData(show: false),

                    barWidth: 4,

                    spots: const [
                      FlSpot(0, 23),

                      FlSpot(1, 25),

                      FlSpot(2, 24),

                      FlSpot(3, 29),

                      FlSpot(4, 31),

                      FlSpot(5, 28),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,

            children: const [
              _ChartLegend(color: AppColors.primary, title: "Income"),

              SizedBox(width: 24),

              _ChartLegend(color: Colors.redAccent, title: "Expense"),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChartLegend extends StatelessWidget {
  final Color color;

  final String title;

  const _ChartLegend({required this.color, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(radius: 5, backgroundColor: color),

        const SizedBox(width: 6),

        Text(title, style: AppTextStyles.caption),
      ],
    );
  }
}
