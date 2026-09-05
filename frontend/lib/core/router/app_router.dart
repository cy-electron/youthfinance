import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/auth/providers/auth_provider.dart';

import '../../features/shell/presentation/screens/app_shell.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';

import '../../features/fun_fund/presentation/screens/fun_fund_screen.dart';
import '../../features/emergency/presentation/screens/emergency_fund_screen.dart';
import '../../features/investment/presentation/screens/investment_screen.dart';
import '../../features/learning/presentation/screens/learning_screen.dart';

import '../../features/notifications/presentation/screens/notification_screen.dart';

import '../../features/profile/presentation/screens/appearance_screen.dart';
import '../../features/profile/presentation/screens/notification_settings_screen.dart';
import '../../features/profile/presentation/screens/privacy_policy_screen.dart';
import '../../features/profile/presentation/screens/support_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: '/',

    routes: [
      // ==========================================================
      // Authentication / Startup
      // ==========================================================
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),

      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),

      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),

      // ==========================================================
      // Main Application
      // ==========================================================
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const AppShell(),
      ),

      // ==========================================================
      // Standalone Features
      // ==========================================================
      GoRoute(
        path: '/fun-fund',
        builder: (context, state) => const FunFundScreen(),
      ),

      GoRoute(
        path: '/emergency-fund',
        builder: (context, state) => const EmergencyFundScreen(),
      ),

      GoRoute(
        path: '/investments',
        builder: (context, state) => const InvestmentScreen(),
      ),

      GoRoute(
        path: '/learning',
        builder: (context, state) => const LearningScreen(),
      ),

      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationScreen(),
      ),

      // ==========================================================
      // Settings / Support
      // ==========================================================
      GoRoute(
        path: '/settings/appearance',
        builder: (context, state) => const AppearanceScreen(),
      ),

      GoRoute(
        path: '/settings/notifications',
        builder: (context, state) => const NotificationSettingsScreen(),
      ),

      GoRoute(
        path: '/settings/privacy',
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),

      GoRoute(
        path: '/support',
        builder: (context, state) => const SupportScreen(),
      ),

      GoRoute(
        path: '/support/faq',
        builder: (context, state) => const SupportScreen(showFaq: true),
      ),
    ],
  );

  // ============================================================
  // Authentication State
  // ============================================================

  ref.listen<AsyncValue>(authProvider, (_, next) {
    if (next.isLoading) {
      return;
    }

    final user = next.valueOrNull;

    if (user != null) {
      router.go('/dashboard');
    } else {
      router.go('/login');
    }
  });

  return router;
});
