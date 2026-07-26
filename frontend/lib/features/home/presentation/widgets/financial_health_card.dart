import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:youthfinance/features/home/presentation/widgets/health_matric.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../design_system/cards/app_card.dart';

class FinancialHealthCard extends StatelessWidget {
  final int score;

  const FinancialHealthCard({super.key, required this.score});

  Color get scoreColor {
    if (score >= 80) return AppColors.success;
    if (score >= 60) return const Color.fromARGB(255, 13, 100, 214);
    return AppColors.expense;
  }

  String get status {
    if (score >= 80) return "Excellent";
    if (score >= 60) return "Good";
    return "Needs Attention";
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---- Top row: title + info icon (left) ... chevron button (right) ----
            Row(
              children: [
                Text("FINANCIAL HEALTH", style: AppTextStyles.sectionTitle),
                const SizedBox(width: 6),
                Icon(
                  Icons.info_outline,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                const Spacer(),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(Icons.chevron_right),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.lg),

            // ---- Main row: circular score (left) + status/points (right) ----
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
                  backgroundColor: AppColors.primaryLight,
                  center: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "$score",
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

                const SizedBox(width: 36),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        status,
                        style: AppTextStyles.cardTitle.copyWith(
                          color: scoreColor,
                          fontSize: 36,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        "+6 pts since last month",
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // ---- Metrics row spanning full card width ----
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Expanded(
                  child: HealthMetric(
                    icon: Icons.savings,
                    title: "Savings",
                    status: "High",
                    progress: .82,
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: HealthMetric(
                    icon: Icons.account_balance_wallet,
                    title: "Budget",
                    status: "Excellent",
                    progress: .90,
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: HealthMetric(
                    icon: Icons.flag,
                    title: "Goals",
                    status: "On Track",
                    progress: .75,
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: HealthMetric(
                    icon: Icons.security,
                    title: "Emergency",
                    status: "Good",
                    progress: .80,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
