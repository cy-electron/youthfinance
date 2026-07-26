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

  final List<Widget> pages = const [
    HomeScreen(),

    TransactionsScreen(),

    GoalsScreen(),

    AnalyticsScreen(),

    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],

      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,

        onDestinationSelected: (index) {
          setState(() {
            currentIndex = index;
          });
        },

        destinations: const [
          // Home: an actual house icon now, not a dashboard grid.
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: "Home",
          ),

          NavigationDestination(
            icon: Icon(Icons.swap_horiz_outlined),
            selectedIcon: Icon(Icons.swap_horiz_rounded),
            label: "Transactions",
          ),

          NavigationDestination(
            icon: Icon(Icons.flag_outlined),
            selectedIcon: Icon(Icons.flag_rounded),
            label: "Goals",
          ),

          // insights_outlined/insights_rounded matches the "Insights"
          // label directly (was analytics_outlined/analytics — a more
          // generic icon for a tab that's specifically named Insights).
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights_rounded),
            label: "Insights",
          ),

          // account_circle reads as a clearer "profile" silhouette than
          // a bare person icon.
          NavigationDestination(
            icon: Icon(Icons.person),
            selectedIcon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
