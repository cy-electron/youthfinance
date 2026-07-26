import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../design_system/layout/app_scaffold.dart';

import '../widgets/monthly_overview_card.dart';
import '../widgets/spending_breakdown_card.dart';
import '../widgets/cashflow_chart.dart';
import '../widgets/health_trend_chart.dart';
import '../widgets/spending_patterns.dart';
import '../widgets/progress_highlight_card.dart';
import '../widgets/future_projection_card.dart';
import '../widgets/financial_reflection_card.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      // No `title` here anymore — using a custom bold header (title +
      // subtitle + single icon button) below instead of AppScaffold's
      // default small AppBar title, matching the design.
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _InsightsHeader(
              onLearnTap: () {
                // TODO: navigate to the Learn & Grow.
                // Wire this up once the actual route/screen name for
                // "Learn & Grow" is known.
              },
            ),

            const SizedBox(height: AppSpacing.xl),

            const MonthlyOverviewCard(),

            SizedBox(height: AppSpacing.xl),

            const SpendingBreakdownCard(),

            SizedBox(height: AppSpacing.xl),

            const CashflowChart(),

            SizedBox(height: AppSpacing.xl),

            const HealthTrendChart(),

            SizedBox(height: AppSpacing.xl),

            const SpendingPatterns(),

            SizedBox(height: AppSpacing.xl),

            const ProgressHighlightCard(),

            SizedBox(height: AppSpacing.xl),

            const FutureProjectionCard(),

            SizedBox(height: AppSpacing.xl),

            const FinancialReflectionCard(),

            SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}

class _InsightsHeader extends StatelessWidget {
  final VoidCallback onLearnTap;

  const _InsightsHeader({required this.onLearnTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Insights",
                style: AppTextStyles.heading.copyWith(fontSize: 28),
              ),

              const SizedBox(height: AppSpacing.xs),

              Text(
                "Understand your financial habits.",
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: AppSpacing.sm),

        // Single outlined circle button (was two before) — links to the
        // Learning section instead of being a generic info button.
        Material(
          color: Colors.white,
          shape: CircleBorder(side: BorderSide(color: Colors.grey.shade300)),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onLearnTap,
            child: const SizedBox(
              width: 45,
              height: 45,
              child: Icon(
                Icons.school_outlined,
                size: 20,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
