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
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: "Home",
          ),

          NavigationDestination(
            icon: Icon(Icons.swap_horiz_outlined),
            selectedIcon: Icon(Icons.swap_horiz),
            label: "Transactions",
          ),

          NavigationDestination(
            icon: Icon(Icons.flag_outlined),
            selectedIcon: Icon(Icons.flag),
            label: "Goals",
          ),

          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics),
            label: "Insights",
          ),

          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
