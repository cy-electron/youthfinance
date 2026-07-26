import 'package:flutter/material.dart';

import '../../../../design_system/cards/app_card.dart';
import '../../../../core/theme/app_spacing.dart';

import 'overview_metric.dart';

class MonthlyOverviewCard extends StatelessWidget {
  const MonthlyOverviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          Row(
            children: const [
              OverviewMetric(
                title: "Income",
                value: "₹42,500",
                change: "+4%",
                positive: true,
              ),

              SizedBox(width: AppSpacing.lg),

              OverviewMetric(
                title: "Expenses",
                value: "₹28,200",
                change: "-2%",
                positive: false,
              ),
            ],
          ),

          SizedBox(height: AppSpacing.xl),

          Row(
            children: const [
              OverviewMetric(
                title: "Savings",
                value: "₹14,300",
                change: "+12%",
                positive: true,
              ),

              SizedBox(width: AppSpacing.lg),

              OverviewMetric(
                title: "Net Balance",
                value: "₹14,300",
                change: "",
                positive: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
