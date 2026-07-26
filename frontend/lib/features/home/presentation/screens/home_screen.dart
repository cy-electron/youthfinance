import 'package:flutter/material.dart';
import 'package:youthfinance/core/theme/app_spacing.dart';
import 'package:youthfinance/features/home/presentation/widgets/active_goals_section.dart';
import 'package:youthfinance/features/home/presentation/widgets/learning_section.dart';
import 'package:youthfinance/features/home/presentation/widgets/monthly_snapshot_section.dart';
import 'package:youthfinance/features/home/presentation/widgets/quick_actions_section.dart';
import 'package:youthfinance/features/home/presentation/widgets/smart_insight_card.dart';
import 'package:youthfinance/features/transactions/presentation/widgets/recent_transactions_section.dart';

import '../widgets/financial_health_card.dart';
import '../../../../design_system/layout/app_scaffold.dart';

import '../widgets/greeting_section.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: SingleChildScrollView(
        child: Column(
          children: const [
            GreetingSection(),

            const SizedBox(height: AppSpacing.xl),

            FinancialHealthCard(score: 78),

            const SizedBox(height: AppSpacing.xl),

            MonthlySnapshotSection(),

            const SizedBox(height: AppSpacing.xl),

            QuickActionsSection(),

            const SizedBox(height: AppSpacing.xl),

            ActiveGoalsSection(),

            const SizedBox(height: AppSpacing.xl),

            SmartInsightSection(),

            const SizedBox(height: AppSpacing.xl),

            LearningSection(),

            const SizedBox(height: AppSpacing.xl),

            RecentTransactionsSection(),
          ],
        ),
      ),
    );
  }
}
