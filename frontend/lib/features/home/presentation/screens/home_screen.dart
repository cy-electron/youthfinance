import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:youthfinance/core/theme/app_spacing.dart';

import 'package:youthfinance/features/home/presentation/widgets/active_goals_section.dart';
import 'package:youthfinance/features/home/presentation/widgets/budget_section.dart';
import 'package:youthfinance/features/home/presentation/widgets/learning_section.dart';
import 'package:youthfinance/features/home/presentation/widgets/monthly_snapshot_section.dart';
import 'package:youthfinance/features/home/presentation/widgets/quick_actions_section.dart';
import 'package:youthfinance/features/home/presentation/widgets/smart_insight_card.dart';
import 'package:youthfinance/features/transactions/presentation/widgets/recent_transactions_section.dart';

import '../widgets/financial_health_card.dart';
import '../widgets/greeting_section.dart';
import '../../../../design_system/layout/app_scaffold.dart';
import '../../../notifications/model/notification_provider.dart';

class HomeScreen extends ConsumerWidget {
  final VoidCallback onNavigateToTransactions;
  final VoidCallback onNavigateToInsights;

  const HomeScreen({
    super.key,
    required this.onNavigateToTransactions,
    required this.onNavigateToInsights,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(unreadNotificationCountProvider);

    return AppScaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            GreetingSection(
              hasUnreadNotifications: unreadCount.valueOrNull != null &&
                  unreadCount.valueOrNull! > 0,
              onNotificationsTap: () => context.push('/notifications'),
            ),

            const SizedBox(height: AppSpacing.xl),

            FinancialHealthCard(onNavigateToInsights: onNavigateToInsights),

            const SizedBox(height: AppSpacing.xl),

            const MonthlySnapshotSection(),

            const SizedBox(height: AppSpacing.xl),

            const QuickActionsSection(),

            const SizedBox(height: AppSpacing.xl),

            const ActiveGoalsSection(),

            const SizedBox(height: AppSpacing.xl),

            SmartInsightSection(
              onNavigateToInsights: onNavigateToInsights,
              ),

            const SizedBox(height: AppSpacing.xl),

            const LearningSection(),

            const SizedBox(height: AppSpacing.xl),

            const BudgetSection(),

            const SizedBox(height: AppSpacing.xl),

            RecentTransactionsSection(
              onNavigateToTransactions: onNavigateToTransactions,
              onViewAll: () {},
            ),
          ],
        ),
      ),
    );
  }
}
