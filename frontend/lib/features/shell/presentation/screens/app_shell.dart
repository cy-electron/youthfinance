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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],

      // ========================================================
      // Bottom Navigation
      // ========================================================
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            currentIndex = index;
          });
        },

        destinations: const [
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

          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights_rounded),
            label: "Insights",
          ),

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
