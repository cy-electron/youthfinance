import 'package:flutter/material.dart';

import '../../../home/presentation/screens/home_screen.dart';
import '../../../transactions/presentation/screens/transaction_screen.dart';
import '../../../goals/presentation/screens/goals_screen.dart';
import '../../../analytics/presentation/screens/insights_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int currentIndex = 0;

  // ============================================================
  // Main application pages
  // ============================================================

  List<Widget> get pages => [
        HomeScreen(
          onNavigateToTransactions: () {
            setState(() {
              currentIndex = 1;
            });
          },
          onNavigateToGoals: () {
            setState(() {
              currentIndex = 2;
            });
          },
          onNavigateToInsights: () {
            setState(() {
              currentIndex = 3;
            });
          },
        ),
        const TransactionsScreen(),
        const GoalsScreen(),
        const AnalyticsScreen(),
        const ProfileScreen(),
      ];

  // ============================================================
  // Build
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: pages[currentIndex],

      // ==========================================================
      // Modern Bottom Navigation
      // ==========================================================

      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          height: 72,

          backgroundColor: Colors.white,

          elevation: 8,

          shadowColor: Colors.black.withValues(alpha: 0.08),

          indicatorColor: colorScheme.primaryContainer,

          indicatorShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),

          labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
            (states) {
              final selected = states.contains(
                WidgetState.selected,
              );

              return TextStyle(
                fontSize: 11.5,
                fontWeight:
                    selected ? FontWeight.w700 : FontWeight.w500,
                color: selected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              );
            },
          ),

          iconTheme: WidgetStateProperty.resolveWith<IconThemeData>(
            (states) {
              final selected = states.contains(
                WidgetState.selected,
              );

              return IconThemeData(
                size: 23,
                color: selected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              );
            },
          ),
        ),

        child: NavigationBar(
          selectedIndex: currentIndex,

          onDestinationSelected: (index) {
            if (index == currentIndex) {
              return;
            }

            setState(() {
              currentIndex = index;
            });
          },

          destinations: const [
            NavigationDestination(
              icon: Icon(
                Icons.home_outlined,
              ),
              selectedIcon: Icon(
                Icons.home_rounded,
              ),
              label: 'Home',
            ),

            NavigationDestination(
              icon: Icon(
                Icons.swap_horiz_outlined,
              ),
              selectedIcon: Icon(
                Icons.swap_horiz_rounded,
              ),
              label: 'Transactions',
            ),

            NavigationDestination(
              icon: Icon(
                Icons.track_changes_outlined,
              ),
              selectedIcon: Icon(
                Icons.track_changes_rounded,
              ),
              label: 'Goals',
            ),

            NavigationDestination(
              icon: Icon(
                Icons.insights_outlined,
              ),
              selectedIcon: Icon(
                Icons.insights_rounded,
              ),
              label: 'Insights',
            ),

            NavigationDestination(
              icon: Icon(
                Icons.person_outline_rounded,
              ),
              selectedIcon: Icon(
                Icons.person_rounded,
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}